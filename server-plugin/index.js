import express from 'express';
import sanitize from 'sanitize-filename';

export const info = {
    id: 'janitor-importer',
    name: 'JanitorAI Character Importer',
    description: 'Import characters from JanitorAI with Cloudflare bypass support via browser bookmarklet',
};

/**
 * Returns the bookmarklet code for extracting JanitorAI characters via browser console.
 * @returns {string} Bookmarklet code
 */
function getJanitorBookmarkletCode() {
    return `(function() {
    let charData = null;

    fetch(window.location.href)
        .then(r => r.text())
        .then(html => {
            const match = html.match(/window\\.mbxM\\.push\\(JSON\\.parse\\("((?:\\\\.|[^"\\\\])*?)"\\)\\)/);

            if (!match) {
                if (window.mbxM && window.mbxM.length > 0) {
                    for (let i = 0; i < window.mbxM.length; i++) {
                        if (window.mbxM[i]?.['Sk--a:a-a--characterStore']?.character) {
                            charData = window.mbxM[i]['Sk--a:a-a--characterStore'].character;
                            downloadCharacter(charData);
                            return;
                        }
                    }
                }
                alert('Failed to extract character data.');
                return;
            }

            try {
                const unescaped = JSON.parse('"' + match[1] + '"');
                const parsedData = JSON.parse(unescaped);
                charData = parsedData['Sk--a:a-a--characterStore']?.character;
                if (!charData) throw new Error('Character not in expected location');
                downloadCharacter(charData);
            } catch(e) {
                alert('Failed to parse character data: ' + e.message);
            }
        })
        .catch(err => {
            alert('Failed to fetch page HTML: ' + err.message);
        });

    function downloadCharacter(charData) {
        const avatarUrl = charData.avatar ? 'https://ella.janitorai.com/bot-avatars/' + charData.avatar : null;

        const processCharacter = async () => {
            let avatarBase64 = null;

            if (avatarUrl) {
                try {
                    const avatarResponse = await fetch(avatarUrl);
                    if (avatarResponse.ok) {
                        const blob = await avatarResponse.blob();
                        const reader = new FileReader();
                        avatarBase64 = await new Promise((resolve) => {
                            reader.onloadend = () => resolve(reader.result);
                            reader.readAsDataURL(blob);
                        });
                    }
                } catch (err) {}
            }

            const tavernCard = {
                spec: 'chara_card_v2',
                spec_version: '2.0',
                data: {
                    name: charData.chat_name || charData.name || 'Unknown',
                    description: (charData.description || '').replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').trim(),
                    personality: charData.personality || '',
                    scenario: charData.scenario || '',
                    first_mes: Array.isArray(charData.first_messages) ? (charData.first_messages[0] || '') : (charData.first_message || ''),
                    mes_example: charData.example_dialogs || '',
                    creator_notes: '',
                    system_prompt: '',
                    post_history_instructions: '',
                    alternate_greetings: Array.isArray(charData.first_messages) ? charData.first_messages.slice(1) : [],
                    character_book: undefined,
                    tags: charData.tags?.map(t => t.name) || [],
                    creator: charData.creator_name || '',
                    character_version: '',
                    extensions: {
                        janitor_uuid: charData.id,
                        janitor_display_name: charData.name,
                        avatar_url: avatarUrl,
                        avatar_base64: avatarBase64
                    }
                }
            };

            const blob = new Blob([JSON.stringify(tavernCard, null, 2)], {type: 'application/json'});
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = (charData.chat_name || charData.name || 'character').replace(/[^a-z0-9]/gi, '_') + '.json';
            a.click();
            URL.revokeObjectURL(url);
            alert('Character downloaded: ' + (charData.chat_name || charData.name) + '.json' + (avatarBase64 ? ' (with avatar)' : ' (without avatar)'));
        };

        processCharacter();
    }
})();`.trim();
}

/**
 * Downloads a character from JanitorAI API.
 * @param {string} uuid Character UUID
 * @returns {Promise<{buffer: Buffer, fileName: string, fileType: string}>}
 * @throws {Error} Throws cloudflareBlock error if Cloudflare blocks the request
 */
async function downloadJannyCharacter(uuid) {
    const result = await fetch('https://api.jannyai.com/api/v1/download', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ characterId: uuid }),
    });

    if (result.ok) {
        const downloadResult = await result.json();
        if (downloadResult.downloadUrl) {
            const imageResult = await fetch(downloadResult.downloadUrl);
            const buffer = Buffer.from(await imageResult.arrayBuffer());
            const fileName = `${sanitize(uuid)}.png`;
            const fileType = imageResult.headers.get('content-type');
            return { buffer, fileName, fileType };
        } else {
            console.error('Janny API failed to download', downloadResult);
        }
    } else if (result.status === 403) {
        // Cloudflare Bot Fight Mode blocked the API request
        console.warn('JanitorAI API returned 403 — Cloudflare block detected for UUID:', uuid);
        const bookmarkletCode = getJanitorBookmarkletCode();
        const pageUrl = `https://janitorai.com/characters/${uuid}`;
        const cfError = new Error('Cloudflare blocked JanitorAI API request');
        cfError.cloudflareBlock = true;
        cfError.status = 403;
        cfError.uuid = uuid;
        cfError.url = pageUrl;
        cfError.bookmarklet = bookmarkletCode;
        throw cfError;
    } else {
        console.error('Janny API returned error', result.statusText, await result.text());
    }

    throw new Error('Failed to download character');
}

/**
 * Initialize the plugin by registering API routes.
 * @param {express.Application} app Express app
 */
export async function init(app) {
    const router = express.Router();

    /**
     * POST /api/plugins/janitor-importer/import
     * Import a character from JanitorAI by UUID
     */
    router.post('/import', async (request, response) => {
        try {
            const { uuid } = request.body;

            if (!uuid) {
                return response.status(400).json({ error: 'UUID is required' });
            }

            // Clean UUID (remove _character suffix if present)
            const cleanUuid = uuid.includes('_character') ? uuid.split('_')[0] : uuid;

            if (!cleanUuid) {
                return response.status(400).json({ error: 'Invalid JanitorAI UUID format' });
            }

            console.log('[JanitorImporter] Downloading character:', cleanUuid);
            const result = await downloadJannyCharacter(cleanUuid);

            if (!result) {
                return response.status(500).json({ error: 'Failed to download character' });
            }

            response.set('Content-Type', result.fileType);
            response.set('Content-Disposition', `attachment; filename="${result.fileName}"`);
            response.set('X-Character-UUID', cleanUuid);
            return response.send(result.buffer);

        } catch (error) {
            // Handle Cloudflare block specially
            if (error.cloudflareBlock) {
                if (!error.uuid || !error.url || !error.bookmarklet) {
                    return response.status(500).json({ error: 'Internal error preparing Cloudflare bypass' });
                }
                return response.status(error.status).json({
                    error: 'cloudflare_block',
                    uuid: error.uuid,
                    url: error.url,
                    bookmarklet: error.bookmarklet,
                });
            }

            console.error('[JanitorImporter] Error:', error);
            return response.status(500).json({ error: error.message || 'Internal server error' });
        }
    });

    /**
     * GET /api/plugins/janitor-importer/bookmarklet
     * Get the bookmarklet code
     */
    router.get('/bookmarklet', (request, response) => {
        return response.json({
            bookmarklet: getJanitorBookmarkletCode(),
        });
    });

    // Register routes
    app.use('/api/plugins/janitor-importer', router);

    console.log('[JanitorImporter] Plugin initialized with API routes:');
    console.log('  POST /api/plugins/janitor-importer/import');
    console.log('  GET  /api/plugins/janitor-importer/bookmarklet');
}

/**
 * Cleanup function called when the plugin is unloaded.
 */
export async function exit() {
    console.log('[JanitorImporter] Plugin unloaded');
}
