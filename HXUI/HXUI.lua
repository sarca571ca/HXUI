--[[
* MIT License
* 
* Copyright (c) 2023 tirem [github.com/tirem]
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
]]--

addon.name      = 'HXUI';
addon.author    = 'Tirem (Programmer) & Shuu (Designer)';
addon.version   = '0.1.0';
addon.desc      = 'Multiple UI elements with manager';
addon.link      = 'https://github.com/tirem/HXUI'

require('common');
local imgui = require('imgui');
local settings = require('settings');
local playerBar = require('playerbar');
local targetBar = require('targetbar');
local enemyList = require('enemylist');
local expBar = require('expbar');
local gilTracker = require('giltracker');
local inventoryTracker = require('inventorytracker');
local partyList = require('partylist');
local configMenu = require('configmenu');
local debuffHandler = require('debuffhandler');

local user_settings = 
T{
	showPlayerBar = true,
	showTargetBar = true,
	showEnemyList = true,
	showExpBar = true,
	showGilTracker = true,
	showInventoryTracker = true,
	showPartyList = true,

	barRoundness = 6.0,

	showPartyListWhenSolo = false,
	maxEnemyListEntries = 8,
	showTargetBarPercent = true,

	playerBarScaleX = 1,
	playerBarScaleY = 1,
	playerBarFontOffset = 0,

	targetBarScaleX = 1,
	targetBarScaleY = 1,
	targetBarFontScale = 1,
	targetBarIconScale = 1,

	enemyListScaleX = 1,
	enemyListScaleY = 1,
	enemyListFontScale = 1,
	enemyListIconScale = 1,

	expBarScaleX = 1,
	expBarScaleY = 1,
	expBarFontOffset = 0,

	gilTrackerScale = 1,
	gilTrackerFontOffset = 0,

	inventoryTrackerScale= 1,
	inventoryTrackerFontOffset = 0,

	partyListScaleX = 1,
	partyListScaleY = 1,
	partyListBuffScale = 1,
	partyListFontOffset = 0,
	partyListStatusTheme = 0;
	partyListTheme = 0; -- 0: HorizonXI, 1: XIV1.0, 2: XIV
};

local user_settings_container = 
T{
	userSettings = user_settings;
};

local default_settings =
T{
	-- settings for the targetbar
	targetBarSettings =
	T{
		barWidth = 500,
		barHeight = 10,
		totBarHeight = 10,
		totBarOffset = 1,
		textScale = 1.2,
		cornerOffset = 5,
		nameXOffset = 12,
		nameYOffset = 9,
		iconSize = 22,
		maxIconColumns = 12,
		font_family = 'Nexa Text-Trial Heavy Italic',
	};

	-- settings for the playerbar
	playerBarSettings =
	T{
		hitAnimSpeed = 2,
		hitDelayLength = .5,
		barWidth = 500,
		barSpacing = 10,
		barHeight = 10,
		textYOffset = -4,
		font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Nexa Text-Trial Heavy Italic',
			font_height = 15,
			color = 0xFFFFFFFF,
			bold = true,
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = true;
		};
	};

	-- settings for enemy list
	enemyListSettings = 
	T{
		barWidth = 125;
		barHeight = 10;
		textScale = 1;
		entrySpacing = 1;
		bgPadding = 7;
		bgTopPadding = -3;
		maxIcons = 5;
		iconSize = 18;
		debuffOffsetX = -10;
		debuffOffsetY = 0;
	};

	-- settings for the exp bar
	expBarSettings =
	T{
		barWidth = 550;
		barHeight = 10;
		jobOffsetY = 0;
		expOffsetY = 0;
		percentOffsetY = 2;
		percentOffsetX = -10;
		job_font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Carlito',
			font_height = 11,
			color = 0xFFFFFFFF,
			bold = false,
			italic = true;
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = false;
		};
		exp_font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Carlito',
			font_height = 11,
			color = 0xFFFFFFFF,
			bold = false,
			italic = true;
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = true;
		};
		percent_font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Carlito',
			font_height = 8,
			color = 0xFFFFFF00,
			bold = false,
			italic = true;
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = true;
		};
	};

	-- settings for gil tracker
	gilTrackerSettings = 
	T{
		iconScale = 30;
		offsetX = -5;
		offsetY = -7;
		font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Carlito',
			font_height = 13,
			color = 0xFFFFFFFF,
			bold = true,
			italic = false;
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = true;
		};
	};

	inventoryTrackerSettings = 
	T{
		columnCount = 5;
		rowCount = 6;
		dotRadius = 5;
		dotSpacing = 2;
		groupSpacing = 10;
		textOffsetY = -3;
		font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Carlito',
			font_height = 13,
			color = 0xFFFFFFFF,
			bold = true,
			italic = false;
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = true;
		};
	};

	partyListSettings = 
	T{
		hpBarWidth = 150,
		tpBarWidth = 100,
		mpBarWidth = 100,
		barHeight = 10,
		barSpacing = 0,
		entrySpacing = 0,

		nameTextOffsetX = 0,
		nameTextOffsetY = 5,
		hpTextOffsetX = -2,
		hpTextOffsetY = -3,
		mpTextOffsetX = -2,
		mpTextOffsetY = -3,
		tpTextOffsetX = -2,
		tpTextOffsetY = -3,

		backgroundPaddingX1 = 0,
		backgroundPaddingX2 = 0,
		backgroundPaddingY1 = 0,
		backgroundPaddingY2 = 0,

		cursorPaddingX1 = 3,
		cursorPaddingX2 = 3,
		cursorPaddingY1 = 3,
		cursorPaddingY2 = 3,
		dotRadius = 3,

		arrowSize = 1;

		iconSize = 20,
		maxIconColumns = 6,
		buffOffset = 10,
		xivBuffOffsetY = 5;

		hp_font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Nexa Text-Trial Heavy Italic',
			font_height = 13,
			color = 0xFFFFFFFF,
			bold = true,
			italic = false;
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = true;
		};
		mp_font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Nexa Text-Trial Heavy Italic',
			font_height = 13,
			color = 0xFFFFFFFF,
			bold = true,
			italic = false;
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = true;
		};
		tp_font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Nexa Text-Trial Heavy Italic',
			font_height = 13,
			color = 0xFFFFFFFF,
			bold = true,
			italic = false;
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = true;
		};
		name_font_settings = 
		T{
			visible = true,
			locked = true,
			font_family = 'Nexa Text-Trial Heavy Italic',
			font_height = 13,
			color = 0xFFFFFFFF,
			bold = true,
			italic = false;
			color_outline = 0xFF000000,
			draw_flags = 0x10,
			background = 
			T{
				visible = false,
			},
			right_justified = false;
		};
		primData = {
			texture_offset_x= 0.0,
			texture_offset_y= 0.0,
			border_visible  = false,
			border_flags    = FontBorderFlags.None,
			border_sizes    = '0,0,0,0',
			visible         = true,
			position_x      = 0,
			position_y      = 0,
			can_focus       = false,
			locked          = true,
			lockedz         = true,
			scale_x         = 1.0,
			scale_y         = 1.0,
			width           = 0.0,
			height          = 0.0,
		};
	};
};

local adjustedSettings = deep_copy_table(default_settings);
local defaultUserSettings = deep_copy_table(user_settings);

local config = settings.load(user_settings_container);

showConfig = { false };

function ResetSettings()
	config.userSettings = deep_copy_table(defaultUserSettings);
end

local function CheckVisibility()
	if (config.userSettings.showPlayerBar == false) then
		playerBar.SetHidden(true);
	end
	if (config.userSettings.showExpBar == false) then
		expBar.SetHidden(true);
	end
	if (config.userSettings.showGilTracker == false) then
		gilTracker.SetHidden(true);
	end
	if (config.userSettings.showInventoryTracker == false) then
		inventoryTracker.SetHidden(true);
	end
	if (config.userSettings.showPartyList == false) then
		partyList.SetHidden(true);
	end
end

local function UpdateFonts()
	playerBar.UpdateFonts(adjustedSettings.playerBarSettings);
	expBar.UpdateFonts(adjustedSettings.expBarSettings);
	gilTracker.UpdateFonts(adjustedSettings.gilTrackerSettings);
	inventoryTracker.UpdateFonts(adjustedSettings.inventoryTrackerSettings);
	partyList.UpdateFonts(adjustedSettings.partyListSettings);
end

local function UpdateUserSettings()
    local ns = default_settings;
	local us = config.userSettings;

	-- Target Bar
	adjustedSettings.targetBarSettings.barWidth = ns.targetBarSettings.barWidth * us.targetBarScaleX;
	adjustedSettings.targetBarSettings.barHeight = ns.targetBarSettings.barHeight * us.targetBarScaleY;
	adjustedSettings.targetBarSettings.totBarHeight = ns.targetBarSettings.totBarHeight * us.targetBarScaleY;
	adjustedSettings.targetBarSettings.textScale = ns.targetBarSettings.textScale * us.targetBarFontScale;
	adjustedSettings.targetBarSettings.iconSize = ns.targetBarSettings.iconSize * us.targetBarIconScale;

	-- Party List
    adjustedSettings.partyListSettings.hpBarWidth = ns.partyListSettings.hpBarWidth * us.partyListScaleX;
    adjustedSettings.partyListSettings.barHeight = ns.partyListSettings.barHeight * us.partyListScaleY;
    adjustedSettings.partyListSettings.tpBarWidth = ns.partyListSettings.tpBarWidth * us.partyListScaleX;
	adjustedSettings.partyListSettings.mpBarWidth = ns.partyListSettings.mpBarWidth * us.partyListScaleX;
    adjustedSettings.partyListSettings.entrySpacing = ns.partyListSettings.entrySpacing * us.partyListScaleY;
    adjustedSettings.partyListSettings.hp_font_settings.font_height = math.max(ns.partyListSettings.hp_font_settings.font_height + us.partyListFontOffset, 1);
    adjustedSettings.partyListSettings.mp_font_settings.font_height = math.max(ns.partyListSettings.mp_font_settings.font_height + us.partyListFontOffset, 1);
	adjustedSettings.partyListSettings.tp_font_settings.font_height = math.max(ns.partyListSettings.tp_font_settings.font_height + us.partyListFontOffset, 1);
    adjustedSettings.partyListSettings.name_font_settings.font_height = math.max(ns.partyListSettings.name_font_settings.font_height + us.partyListFontOffset, 1);
	adjustedSettings.partyListSettings.backgroundPaddingX1 = ns.partyListSettings.backgroundPaddingX1 * us.partyListScaleX;
	adjustedSettings.partyListSettings.backgroundPaddingX2 = ns.partyListSettings.backgroundPaddingX2 * us.partyListScaleX;
	adjustedSettings.partyListSettings.backgroundPaddingY1 = ns.partyListSettings.backgroundPaddingY1 * us.partyListScaleY;
	adjustedSettings.partyListSettings.backgroundPaddingY2 = ns.partyListSettings.backgroundPaddingY2 * us.partyListScaleY;
	adjustedSettings.partyListSettings.cursorPaddingX1 = ns.partyListSettings.cursorPaddingX1 * us.partyListScaleX;
	adjustedSettings.partyListSettings.cursorPaddingX2 = ns.partyListSettings.cursorPaddingX2 * us.partyListScaleX;
	adjustedSettings.partyListSettings.cursorPaddingY1 = ns.partyListSettings.cursorPaddingY1 * us.partyListScaleY;
	adjustedSettings.partyListSettings.cursorPaddingY2 = ns.partyListSettings.cursorPaddingY2 * us.partyListScaleY;
	adjustedSettings.partyListSettings.iconSize = ns.partyListSettings.iconSize * us.partyListBuffScale;

	-- Player Bar
	adjustedSettings.playerBarSettings.barWidth = ns.playerBarSettings.barWidth * us.playerBarScaleX;
	adjustedSettings.playerBarSettings.barSpacing = ns.playerBarSettings.barSpacing * us.playerBarScaleX;
	adjustedSettings.playerBarSettings.barHeight = ns.playerBarSettings.barHeight * us.playerBarScaleY;
	adjustedSettings.playerBarSettings.font_settings.font_height = math.max(ns.playerBarSettings.font_settings.font_height + us.playerBarFontOffset, 1);

	-- Exp Bar
	adjustedSettings.expBarSettings.barWidth = ns.expBarSettings.barWidth * us.expBarScaleX;
	adjustedSettings.expBarSettings.barHeight = ns.expBarSettings.barHeight * us.expBarScaleY;
	adjustedSettings.expBarSettings.job_font_settings.font_height = math.max(ns.expBarSettings.job_font_settings.font_height + us.expBarFontOffset, 1);
	adjustedSettings.expBarSettings.exp_font_settings.font_height = math.max(ns.expBarSettings.exp_font_settings.font_height + us.expBarFontOffset, 1);
	adjustedSettings.expBarSettings.percent_font_settings.font_height = math.max(ns.expBarSettings.percent_font_settings.font_height + us.expBarFontOffset, 1);

	-- Gil Tracker
	adjustedSettings.gilTrackerSettings.iconScale = ns.gilTrackerSettings.iconScale * us.gilTrackerScale;
	adjustedSettings.gilTrackerSettings.font_settings.font_height = math.max(ns.gilTrackerSettings.font_settings.font_height + us.gilTrackerFontOffset, 1);
	
	-- Inventory Tracker
	adjustedSettings.inventoryTrackerSettings.dotRadius = ns.inventoryTrackerSettings.dotRadius * us.inventoryTrackerScale;
	adjustedSettings.inventoryTrackerSettings.dotSpacing = ns.inventoryTrackerSettings.dotSpacing * us.inventoryTrackerScale;
	adjustedSettings.inventoryTrackerSettings.groupSpacing = ns.inventoryTrackerSettings.groupSpacing * us.inventoryTrackerScale;
	adjustedSettings.inventoryTrackerSettings.font_settings.font_height = math.max(ns.inventoryTrackerSettings.font_settings.font_height + us.inventoryTrackerFontOffset, 1);

	-- Enemy List
	adjustedSettings.enemyListSettings.barWidth = ns.enemyListSettings.barWidth * us.enemyListScaleX;
	adjustedSettings.enemyListSettings.barHeight = ns.enemyListSettings.barHeight * us.enemyListScaleY;
	adjustedSettings.enemyListSettings.textScale = ns.enemyListSettings.textScale * us.enemyListFontScale;
	adjustedSettings.enemyListSettings.iconSize = ns.enemyListSettings.iconSize * us.enemyListIconScale;
end

function UpdateSettings()
    -- Save the current settings..
    settings.save();

	UpdateUserSettings();
	CheckVisibility();
	UpdateFonts();
end;

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        config = s;
		UpdateSettings();
    end
end);

--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()

	imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, config.userSettings.barRoundness);
	if (config.userSettings.showPlayerBar) then
		playerBar.DrawWindow(adjustedSettings.playerBarSettings, config.userSettings);
	end
	if (config.userSettings.showTargetBar) then
		targetBar.DrawWindow(adjustedSettings.targetBarSettings, config.userSettings);
	end
	if (config.userSettings.showEnemyList) then
		enemyList.DrawWindow(adjustedSettings.enemyListSettings, config.userSettings);
	end
	if (config.userSettings.showExpBar) then
		expBar.DrawWindow(adjustedSettings.expBarSettings, config.userSettings);
	end
	if (config.userSettings.showGilTracker) then
		gilTracker.DrawWindow(adjustedSettings.gilTrackerSettings, config.userSettings);
	end
	if (config.userSettings.showInventoryTracker) then
		inventoryTracker.DrawWindow(adjustedSettings.inventoryTrackerSettings, config.userSettings);
	end
	if (config.userSettings.showPartyList) then
		partyList.DrawWindow(adjustedSettings.partyListSettings, config.userSettings);
	end

	configMenu.DrawWindow(config.userSettings);

	imgui.PopStyleVar(1);
end);

ashita.events.register('load', 'load_cb', function ()

	UpdateUserSettings();
    playerBar.Initialize(adjustedSettings.playerBarSettings);
	expBar.Initialize(adjustedSettings.expBarSettings);
	gilTracker.Initialize(adjustedSettings.gilTrackerSettings);
	inventoryTracker.Initialize(adjustedSettings.inventoryTrackerSettings);
	partyList.Initialize(adjustedSettings.partyListSettings);
end);

ashita.events.register('command', 'command_cb', function (e)
   
	-- Parse the command arguments
	local command_args = e.command:lower():args()
    if table.contains({'/horizonui', '/hui', '/hxui', '/horizonxiui'}, command_args[1]) then
		-- Toggle the config menu
		showConfig[1] = not showConfig[1];
		e.blocked = true;
	end

end);

-- Track our packets
ashita.events.register('packet_in', 'packet_in_cb', function (e)
	if (e.id == 0x0028) then
		local actionPacket = ParseActionPacket(e);
		if (config.userSettings.showEnemyList) then
			enemyList.HandleActionPacket(actionPacket);
		end
	elseif (e.id == 0x00E) then
		local mobUpdatePacket = ParseMobUpdatePacket(e);
		if (config.userSettings.showEnemyList) then
			enemyList.HandleMobUpdatePacket(mobUpdatePacket);
		end
	elseif (e.id == 0x00A) then
		enemyList.HandleZonePacket(e);
		partyList.HandleZonePacket(e);
	end
	debuffHandler.HandlePacket(e);
end);
