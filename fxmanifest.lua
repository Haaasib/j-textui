fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name         'jomidar-textui'
version      '1.1.1'
description  'A multi-framework nopixel v4 text ui'
author       'mfhasib'

shared_scripts {
    'shared/*.lua'
}
client_scripts {
	'client/*.lua'
}
ui_page 'html/index.html'
files {
	'html/index.html',
	'html/style.css',
	'html/index.js',
	'assets/**/*.png'
}
lua54 'yes'
exports {
    'displayTextUI',
    'hideTextUI',
	'changeText',
	'create3DTextUI',
	'update3DTextUI',
	'create3DTextUIOnPlayers',
	'delete3DTextUIOnPlayers',
	'delete3DTextUI',
	'create3DTextUIOnEntity'
}
dependency '/assetpacks'