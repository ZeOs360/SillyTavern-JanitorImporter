import { processDroppedFiles, getRequestHeaders } from '../../../script.js';
import { extension_settings, renderExtensionTemplateAsync } from '../../extensions.js';
import { callGenericPopup, POPUP_TYPE } from '../../popup.js';

const extensionName = 'janitor-importer';

let settings = {
    enabled: true,
};

/**
 * Shows a modal with instructions to bypass Cloudflare protection for JanitorAI.
 * @param {Object} errorData Error data from the server
 * @param {string} errorData.uuid Character UUID
 * @param {string} errorData.url Character page URL
 * @param {string} errorData.bookmarklet Bookmarklet code
 */
async function showCloudflareBypassModal(errorData) {
    try {
        // Validate errorData
        if (!errorData?.url || !errorData?.bookmarklet) {
            console.error('[JanitorImporter] Invalid errorData for Cloudflare bypass modal:', errorData);
            toastr.error('Failed to show Cloudflare bypass instructions. Missing required data.');
            return;
        }

        // We use sanitize=false because DOMPurify would strip the bookmarklet
        // JavaScript code from the template. The bookmarklet is rendered via
        // {{{bookmarklet}}} (triple-mustache = raw/unescaped) in the template.
        // This is safe because the bookmarklet content comes from our own server
        // plugin, not from user input.
        const html = await renderExtensionTemplateAsync(
            extensionName,
            'janitorCloudflareBypass',
            errorData,
            false,  // sanitize=false: bookmarklet contains JS that DOMPurify would strip
            true,   // localize
        );

        // Show the popup (don't await yet, we need to set up handlers first)
        const popupPromise = callGenericPopup(html, POPUP_TYPE.TEXT, '', {
            wide: true,
            large: true,
            allowVerticalScrolling: true,
            okButton: 'Close',
        });

        // Wait for popup to be in DOM
        await new Promise(resolve => setTimeout(resolve, 100));

        // Set up copy button handler — reads the raw bookmarklet from errorData, not the DOM
        const copyBtn = document.getElementById('copy-bookmarklet-btn');
        if (copyBtn) {
            copyBtn.addEventListener('click', () => {
                const code = errorData.bookmarklet;
                navigator.clipboard.writeText(code).then(() => {
                    toastr.success('Code copied to clipboard!');
                }).catch(err => {
                    console.error('[JanitorImporter] Failed to copy:', err);
                    toastr.error('Failed to copy code. Please select and copy manually.');
                });
            });
        }

        // Set up drag & drop zone
        const dropZone = document.getElementById('janitor-drop-zone');
        const fileInput = document.getElementById('janitor-file-input');

        if (dropZone && fileInput) {
            dropZone.addEventListener('click', () => {
                fileInput.click();
            });

            dropZone.addEventListener('dragover', (e) => {
                e.preventDefault();
                e.stopPropagation();
                dropZone.classList.add('dragover');
            });

            dropZone.addEventListener('dragleave', (e) => {
                e.preventDefault();
                e.stopPropagation();
                dropZone.classList.remove('dragover');
            });

            dropZone.addEventListener('drop', async (e) => {
                e.preventDefault();
                e.stopPropagation();
                dropZone.classList.remove('dragover');

                const files = Array.from(e.dataTransfer?.files || []).filter(f => f.name.endsWith('.json'));
                if (files.length > 0) {
                    // Close the modal
                    $('#dialogue_popup_cancel').trigger('click');
                    // Import the files
                    try {
                        await processDroppedFiles(files);
                    } catch (err) {
                        console.error('[JanitorImporter] Error processing dropped files:', err);
                        toastr.error('Failed to import character file.');
                    }
                }
            });

            fileInput.addEventListener('change', async (e) => {
                const files = Array.from(e.target?.files || []);
                if (files.length > 0) {
                    // Close the modal
                    $('#dialogue_popup_cancel').trigger('click');
                    // Import the files
                    try {
                        await processDroppedFiles(files);
                    } catch (err) {
                        console.error('[JanitorImporter] Error processing selected files:', err);
                        toastr.error('Failed to import character file.');
                    }
                    // Reset so the same file can be re-selected if needed
                    e.target.value = '';
                }
            });
        }

        // Now await the popup result
        await popupPromise;
    } catch (error) {
        console.error('[JanitorImporter] Error showing Cloudflare bypass modal:', error);
        toastr.error('Failed to show modal. Check console for details.');
    }
}

/**
 * Import a character from JanitorAI URL or UUID.
 * @param {string} input JanitorAI character URL or UUID (e.g. "uuid_character")
 */
async function importFromJanitorUrl(input) {
    try {
        let uuid;

        // Try to extract UUID from URL
        const urlMatch = input.match(/janitorai\.com\/characters\/([a-f0-9-]+)/i);
        if (urlMatch) {
            uuid = urlMatch[1];
        } else if (input.includes('_character')) {
            // UUID format from ST's importUUID: "uuid_character"
            uuid = input.split('_')[0];
        } else {
            // Assume it's a raw UUID
            uuid = input.trim();
        }

        if (!uuid) {
            toastr.error('Invalid JanitorAI character identifier');
            return;
        }

        console.log('[JanitorImporter] Importing character:', uuid);

        // Call the plugin API
			const response = await fetch('/api/plugins/janitor-importer/import', {
            method: 'POST',
            headers: getRequestHeaders(), // CSRF Token buraya otomatik eklenecek
            body: JSON.stringify({ uuid }),
        });

        if (!response.ok) {
            // Check if this is a Cloudflare block error
            const contentType = response.headers.get('Content-Type');
            if (contentType && contentType.includes('application/json')) {
                try {
                    const errorData = await response.json();
                    if (errorData.error === 'cloudflare_block') {
                        // Show special Cloudflare bypass modal
                        await showCloudflareBypassModal(errorData);
                        return;
                    }
                } catch (e) {
                    // Not JSON, fall through to normal error handling
                }
            }
            toastr.error(response.statusText, 'JanitorAI import failed');
            console.error('[JanitorImporter] Import failed:', response.status, response.statusText);
            return;
        }

        // Import successful - download the character
        const blob = await response.blob();
        const fileName = response.headers.get('Content-Disposition')?.match(/filename="(.+)"/)?.[1] || 'character.png';

        // Create a File object and process it
        const file = new File([blob], fileName, { type: response.headers.get('Content-Type') });
        await processDroppedFiles([file]);

        toastr.success('Character imported successfully!');
    } catch (error) {
        console.error('[JanitorImporter] Import error:', error);
        toastr.error('Failed to import character. Check console for details.');
    }
}

/**
 * Intercept fetch calls to /api/content/importURL so that JanitorAI URLs are
 * routed through our plugin endpoint instead of the built-in ST handler.
 *
 * Why fetch-patching instead of monkey-patching importFromExternalUrl:
 *   importFromExternalUrl is an ES module export — it is NOT on window, so
 *   window.importFromExternalUrl is always undefined. Patching fetch is the
 *   only reliable way to intercept the request without modifying ST core.
 */
function setupImportInterceptor() {
    const originalFetch = window.fetch.bind(window);

    window.fetch = async function (input, init) {
        const fetchUrl = typeof input === 'string' ? input : input instanceof Request ? input.url : String(input);

        // Only intercept the ST content import endpoints
        const isImportURL = fetchUrl === '/api/content/importURL' && init?.method === 'POST';
        const isImportUUID = fetchUrl === '/api/content/importUUID' && init?.method === 'POST';

        if (isImportURL || isImportUUID) {
            let body;
            try {
                body = JSON.parse(init.body);
            } catch {
                // Not JSON — let it pass through
                return originalFetch(input, init);
            }

            const value = body?.url ?? '';

            // Match JanitorAI URLs (importURL path)
            const isJanitorUrl = isImportURL && value.includes('janitorai.com/characters/');
            // Match JanitorAI UUIDs (importUUID path) — ST sends "uuid_character"
            const isJanitorUuid = isImportUUID && value.includes('_character');

            if (isJanitorUrl || isJanitorUuid) {
                console.log('[JanitorImporter] Intercepted JanitorAI import:', value);
                // Handle it ourselves, then return a synthetic non-ok Response.
                // ST's importFromExternalUrl does:
                //   if (!request.ok) { toastr.info(request.statusText, ...); return; }
                // By returning statusText='' the toastr shows nothing, so the user
                // only sees our own toastr messages (success or the bypass modal).
                await importFromJanitorUrl(value);
                return new Response(null, { status: 499, statusText: '' });
            }
        }

        return originalFetch(input, init);
    };

    console.log('[JanitorImporter] Fetch interceptor installed for JanitorAI URLs');
}

/**
 * Initialize the extension.
 */
async function init() {
    // Load settings
    extension_settings[extensionName] = extension_settings[extensionName] || {};
    Object.assign(settings, extension_settings[extensionName]);

    // Set up fetch interceptor before anything else runs
    setupImportInterceptor();

    console.log('[JanitorImporter] Extension initialized');
}

// Register the extension
jQuery(async () => {
    await init();
});
