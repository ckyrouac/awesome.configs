-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
local menubar = require("menubar")
-- Vicious widget library
vicious = require("vicious")
-- Scratch
local scratch = require("scratch")
local alttab = require("alttab")
--local cyclefocus = require('cyclefocus')
local blingbling = require("blingbling")
local lpass = require("lpass")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Naughty config
naughty.config.defaults.screen           = 2
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/chris/.config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminal-tmux"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.max,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "dev", 2, 3, 4 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Vicioius widgets
separator = wibox.widget.textbox()
separator:set_text(" | ")
padding = wibox.widget.textbox()
padding:set_text("  ")
datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, "%a %b %e, %I:%M%p", 1)
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, "$1% ($2MB/$3MB)")
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%")
batterywidget = wibox.widget.textbox()
vicious.register(batterywidget, vicious.widgets.bat, "$1 $2% $3", 15, "BAT0")
wifiwidget = wibox.widget.textbox()
vicious.register(wifiwidget, vicious.widgets.wifi, "${ssid} ${linp}%", 2, "wlp3s0")
networkwidget = wibox.widget.textbox()
vicious.register(networkwidget, vicious.widgets.net, "▼ ${em1 down_kb}kb ▲ ${em1 up_kb}kb", 2)

-- alttab
alttab.settings.preview_box = true                 -- display preview-box
alttab.settings.preview_box_bg = "#555753"       -- background color
alttab.settings.preview_box_border = "#3465A4"   -- border-color
alttab.settings.preview_box_fps = 30               -- refresh framerate
alttab.settings.preview_box_delay = 150            -- delay in ms

alttab.settings.client_opacity = true             -- set opacity for unselected clients
alttab.settings.client_opacity_value = 1.0         -- alpha-value
alttab.settings.client_opacity_delay = 150         -- delay in ms

-- bling bling widgets
-- calendar
blingcal= blingbling.calendar.new({type = "imagebox", image = beautiful.calendar_icon})
--blingcal = blingbling.calendar()
blingcal:set_link_to_external_calendar(true)
blingvoltext = wibox.widget.textbox()
blingvoltext:set_text("Volume")
blingvol = blingbling.volume({height = 18, width = 40})
blingvol:update_master()
blingvol:set_master_control()
blingnet = blingbling.net()
blingnet:set_interface("em1")
blingnet:set_show_text(true)
blingnet:set_ippopup()
blingcpugraph = blingbling.line_graph()
blingcpugraph:set_show_text(true)
blingcpugraph:set_label(" CPU $percent%")
blingcpugraph:set_width(200)
blingcpugraph:set_height(25)
blingbling.popups.htop(blingcpugraph,
        {terminal = "terminal"})
vicious.register(blingcpugraph, vicious.widgets.cpu,'$1',2)
blingmemwidget=blingbling.line_graph()
blingmemwidget:set_show_text(true)
blingmemwidget:set_label(" MEM $percent%")
blingmemwidget:set_width(200)
blingmemwidget:set_height(25)
vicious.register(blingmemwidget, vicious.widgets.mem, '$1', 2)
blingwifissid = wibox.widget.textbox()
blingwifissid:set_text("$ssid")
vicious.register(blingwifissid, vicious.widgets.wifi, "${ssid}", 10, "wlp3s0")
blingwifiwidget=blingbling.triangular_progressgraph({bar = true})
blingwifiwidget:set_width(40)
vicious.register(blingwifiwidget, vicious.widgets.wifi, "${linp}", 2, "wlp3s0")
blingbatterywidget = blingbling.progress_graph()
blingbatterywidget:set_rounded_size(0)
blingbatterywidget:set_horizontal(true)
blingbatterywidget:set_width(50)
blingbatterywidget:set_show_text(true)
vicious.register(blingbatterywidget, vicious.widgets.bat, "$2", 15, "BAT0")
blingchargingwidget = wibox.widget.textbox()
vicious.register(blingchargingwidget, vicious.widgets.bat, "$1", 2, "BAT0")

-- {{{ Toggle monitors
-- Get active outputs
local function outputs()
   local outputs = {}
   local xrandr = io.popen("xrandr -q")
   if xrandr then
      for line in xrandr:lines() do
	 output = line:match("^([%w-]+) connected ")
	 if output then
	    outputs[#outputs + 1] = output
	 end
      end
      xrandr:close()
   end

   return outputs
end

local function arrange(out)
   -- We need to enumerate all the way to combinate output. We assume
   -- we want only an horizontal layout.
   local choices  = {}
   local previous = { {} }
   for i = 1, #out do
      -- Find all permutation of length `i`: we take the permutation
      -- of length `i-1` and for each of them, we create new
      -- permutations by adding each output at the end of it if it is
      -- not already present.
      local new = {}
      for _, p in pairs(previous) do
	 for _, o in pairs(out) do
	    if not awful.util.table.hasitem(p, o) then
	       new[#new + 1] = awful.util.table.join(p, {o})
	    end
	 end
      end
      choices = awful.util.table.join(choices, new)
      previous = new
   end

   return choices
end

-- Build available choices
local function menu()
   local menu = {}
   local out = outputs()
   local choices = arrange(out)

   for _, choice in pairs(choices) do
      local cmd = "xrandr"
      -- Enabled outputs
      for i, o in pairs(choice) do
	 cmd = cmd .. " --output " .. o .. " --auto"
	 if i > 1 then
	    cmd = cmd .. " --right-of " .. choice[i-1]
	 end
      end
      -- Disabled outputs
      for _, o in pairs(out) do
	 if not awful.util.table.hasitem(choice, o) then
	    cmd = cmd .. " --output " .. o .. " --off"
	 end
      end

      local label = ""
      if #choice == 1 then
	 label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
      else
	 for i, o in pairs(choice) do
	    if i > 1 then label = label .. " + " end
	    label = label .. '<span weight="bold">' .. o .. '</span>'
	 end
      end

      menu[#menu + 1] = { label,
			  cmd,
                          "/usr/share/icons/Tango/32x32/devices/display.png"}
   end

   return menu
end

-- Display xrandr notifications from choices
local state = { iterator = nil,
		timer = nil,
		cid = nil }
local function xrandr()
   -- Stop any previous timer
   if state.timer then
      state.timer:stop()
      state.timer = nil
   end

   -- Build the list of choices
   if not state.iterator then
      state.iterator = awful.util.table.iterate(menu(),
					function() return true end)
   end

   -- Select one and display the appropriate notification
   local next  = state.iterator()
   local label, action, icon
   if not next then
      label, icon = "Keep the current configuration", "/usr/share/icons/Tango/32x32/devices/display.png"
      state.iterator = nil
   else
      label, action, icon = unpack(next)
   end
   state.cid = naughty.notify({ text = label,
				icon = icon,
				timeout = 4,
				screen = mouse.screen, -- Important, not all screens may be visible
				font = "Free Sans 18",
				replaces_id = state.cid }).id

   -- Setup the timer
   state.timer = timer { timeout = 4 }
   state.timer:connect_signal("timeout",
			  function()
			     state.timer:stop()
			     state.timer = nil
			     state.iterator = nil
			     if action then
				awful.util.spawn(action, false)
			     end
			  end)
   state.timer:start()
end
-- }}}


-- {{{ Wibox

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    --mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s})

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(padding)
    right_layout:add(blingmemwidget)
    right_layout:add(separator)
    right_layout:add(blingcpugraph)
    right_layout:add(separator)
    right_layout:add(blingnet)
    right_layout:add(separator)
    right_layout:add(blingwifissid)
    right_layout:add(padding)
    right_layout:add(blingwifiwidget)
    right_layout:add(separator)
    right_layout:add(blingvoltext)
    right_layout:add(padding)
    right_layout:add(blingvol)
    right_layout:add(separator)
    right_layout:add(blingchargingwidget)
    right_layout:add(blingbatterywidget)
    right_layout:add(separator)
    right_layout:add(blingcal)
    right_layout:add(padding)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    -- cycle through all clients.
    --awful.key({ "Mod1",         }, "Tab", function(c)
            --cyclefocus.cycle(1, {modifier="Alt_L"})
    --end),
    --awful.key({ "Mod1", "Shift" }, "Tab", function(c)
            --cyclefocus.cycle(-1, {modifier="Alt_L"})
    --end),
    --cyclefocus.key({ "Mod1", }, "Tab", 1, {
            --cycle_filters = { cyclefocus.filters.same_screen, cyclefocus.filters.common_tag },
            --keys = {'Tab', 'ISO_Left_Tab'}  -- default, could be left out
    --}),
    --cyclefocus.key({ "Mod1", "Shift" }, "Tab", -1, {
            --cycle_filters = { cyclefocus.filters.same_screen, cyclefocus.filters.common_tag },
            --keys = {'Tab', 'ISO_Left_Tab'}  -- default, could be left out
    --}),
    ---- Alt-`: cycle through clients with the same class name.
    --cyclefocus.key({ "Mod1", }, "`", 1, {
            --cycle_filter = function (c, source_c) return c.class == source_c.class end,
            --keys = { "°", "^" },
    --}),
    --cyclefocus.key({ "Mod1", "Shift", }, "`", -1, {
            --cycle_filter = function (c, source_c) return c.class == source_c.class end,
            --keys = { "°", "`" }, 
    --}),
    --awful.key({ "Mod1",           }, "Tab",
        --function ()
            --awful.client.focus.byidx( 1)
            --if client.focus then client.focus:raise() end
        --end),
    --awful.key({ "Mod1", "Shift"}, "Tab",
        --function ()
            --awful.client.focus.byidx(-1)
            --if client.focus then client.focus:raise() end
        --end),
    awful.key({ "Mod1",           }, "Tab",
        function ()
            alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")
        end       
    ),
  
    awful.key({ "Mod1", "Shift"   }, "Tab",
        function ()
            alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
        end
    ),
    awful.key({ "Mod1",           }, "F11",
        function ()
            lpass.toggle()
        end
    ),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    --awful.key({ modkey,           }, "Tab",
        --function ()
            --awful.client.focus.history.previous()
            --if client.focus then
                --client.focus:raise()
            --end
        --end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    --awful.key({ "Mod1" },            "space",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    --awful.key({ modkey }, "p", function() menubar.show() end),
    -- Dropdown terminal
    awful.key({ "Shift" }, "F12", function () scratch.drop("terminal", "bottom", "center", 1, 0.5) end),
    -- brightness
    awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 15") end),
    awful.key({ }, "XF86MonBrightnessUp", function() awful.util.spawn("xbacklight -inc 15") end),
    -- screenlock
    awful.key({ modkey, "Control" }, "l", function() awful.util.spawn("xscreensaver-command -lock") end),
    awful.key({modkey,            }, "F1",     function () awful.screen.focus(1) end),
    awful.key({modkey,            }, "F2",     function () awful.screen.focus(2) end),
    awful.key({modkey,            }, "p", xrandr)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ "Mod1",           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     size_hints_honor = false,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

--client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
--client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- start rofi
os.execute("run_once rofi_custom")
os.execute("run_once xscreensaver")
-- }}}
