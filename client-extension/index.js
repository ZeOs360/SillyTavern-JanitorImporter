import { saveSettingsDebounced, processDroppedFiles } from '../../../script.js';
import { extension_settings } from '../../extensions.js';
import { callGenericPopup, POPUP_TYPE } from '../../popup.js';
import { renderTemplateAsync } from '../../templates.js';

const extensionName = 'janitor-importer';
const extensionFolderPath = `scripts/extensions/${extensionName}`;

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

        const html = await renderTemplateAsync(
            `${extensionFolderPath}/janitorCloudflareBypass`,
            errorData,
            true,
            true,
            true  // fullPath = true
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

        // Set up copy button handler
        const copyBtn = document.getElementById('copy-bookmarklet-btn');
        const codeBlock = document.getElementById('bookmarklet-code');
        if (copyBtn && codeBlock) {
            copyBtn.addEventListener('click', () => {
                const code = codeBlock.textContent;
                if (code) {
                    navigator.clipboard.writeText(code).then(() => {
                        toastr.success('Code copied to clipboard!');
                    }).catch(err => {
                        console.error('[JanitorImporter] Failed to copy:', err);
                        toastr.error('Failed to copy code. Please select and copy manually.');
                    });
                }
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
                dropZone.style.borderColor = 'var(--SmartThemeQuoteColor)';
                dropZone.style.background = 'var(--black50a)';
            });

            dropZone.addEventListener('dragleave', (e) => {
                e.preventDefault();
                e.stopPropagation();
                dropZone.style.borderColor = 'var(--SmartThemeBorderColor)';
                dropZone.style.background = 'var(--black30a)';
            });

            dropZone.addEventListener('drop', async (e) => {
                e.preventDefault();
                e.stopPropagation();
                dropZone.style.borderColor = 'var(--SmartThemeBorderColor)';
                dropZone.style.background = 'var(--black30a)';

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
 * Import a character from JanitorAI URL.
 * @param {string} url JanitorAI character URL
 */
async function importFromJanitorUrl(url) {
    try {
        // Extract UUID from URL
        const match = url.match(/janitorai\.com\/characters\/([a-f0-9-]+)/i);
        if (!match) {
            toastr.error('Invalid JanitorAI character URL');
            return;
        }

        const uuid = match[1];
        console.log('[JanitorImporter] Importing character:', uuid);

        // Call the plugin API
        const response = await fetch('/api/plugins/janitor-importer/import', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
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
 * Intercept the default import URL function to handle JanitorAI URLs.
 */
function setupImportInterceptor() {
    // We'll hook into the existing import system
    const originalImportFromUrl = window.importFromExternalUrl;
    if (typeof originalImportFromUrl === 'function') {
        window.importFromExternalUrl = async function(url, options) {
            // Check if it's a JanitorAI URL
            if (url.includes('janitorai.com/characters/')) {
                await importFromJanitorUrl(url);
                return;
            }
            // Otherwise, use the original function
            return originalImportFromUrl(url, options);
        };
        console.log('[JanitorImporter] Import interceptor installed');
    }
}

/**
 * Initialize the extension.
 */
async function init() {
    // Load settings
    extension_settings[extensionName] = extension_settings[extensionName] || {};
    Object.assign(settings, extension_settings[extensionName]);

    console.log('[JanitorImporter] Extension initialized');
    console.log('[JanitorImporter] Settings:', settings);

    // Set up import interceptor
    setupImportInterceptor();
}

// Register the extension
jQuery(async () => {
    await init();
});

// Export functions for use by other modules
export { showCloudflareBypassModal, importFromJanitorUrl };
