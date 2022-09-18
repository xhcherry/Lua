util.require_natives("natives-1660775568-uno")
util.toast("欢迎来到JinxScript!\n" .. "官网Discord: https://discord.gg/hjs5S93kQv")
local response = false
local localVer = 2.43
async_http.init("raw.githubusercontent.com", "/Prisuhm/JinxScript/main/JinxScriptVersion", function(output)
    currentVer = tonumber(output)
    response = true
    if localVer ~= currentVer then
        util.toast("新版本已推送,更新脚本来获取最新版本.")
        menu.action(menu.my_root(), "更新此脚本", {}, "点击后会导致全英文，等Jinx中文区更新", function()
            async_http.init('raw.githubusercontent.com', '/Prisuhm/JinxScript/main/JinxScript.lua', function(a)
                local err = select(2, load(a))
                if err then
                    util.toast("脚本下载失败,请稍后重试,如果这种情况继续发生,请通过 Github 手动更新.")
                    return
                end
                local f = io.open(filesystem.scripts_dir() .. SCRIPT_RELPATH, "wb")
                f:write(a)
                f:close()
                util.toast("更新成功,请重启脚本:)")
                util.restart_script()
            end)
            async_http.dispatch()
        end)
    end
end, function()
    response = true
end)
async_http.dispatch()
repeat
    util.yield()
until response

local function player_toggle_loop(root, pid, menu_name, command_names, help_text, callback)
    return menu.toggle_loop(root, menu_name, command_names, help_text, function()
        if not players.exists(pid) then
            util.stop_thread()
        end
        callback()
    end)
end

local spawned_objects = {}
local function get_transition_state(pid)
    return memory.read_int(memory.script_global(((0x2908D3 + 1) + (pid * 0x1C5)) + 230))
end

local function get_interior_player_is_in(pid)
    return memory.read_int(memory.script_global(((0x2908D3 + 1) + (pid * 0x1C5)) + 243))
end

local function is_player_in_interior(pid)
    return (memory.read_int(memory.script_global(0x2908D3 + 1 + (pid * 0x1C5) + 243)) ~= 0)
end

local function clearBit(addr, bitIndex)
    memory.write_int(addr, memory.read_int(addr) & ~(1 << bitIndex))
end
local function BlockSyncs(pid, callback)
    for _, i in ipairs(players.list(false, true, true)) do
        if i ~= pid then
            local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
            menu.trigger_command(outSync, "on")
        end
    end
    util.yield(10)
    callback()
    for _, i in ipairs(players.list(false, true, true)) do
        if i ~= pid then
            local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
            menu.trigger_command(outSync, "off")
        end
    end
end

local function custom_alert(l1)
    -- totally not skidded from lancescript
    poptime = os.time()
    while true do
        if PAD.IS_CONTROL_JUST_RELEASED(18, 18) then
            if os.time() - poptime > 0.1 then
                break
            end
        end
        native_invoker.begin_call()
        native_invoker.push_arg_string("ALERT")
        native_invoker.push_arg_string("JL_INVITE_ND")
        native_invoker.push_arg_int(2)
        native_invoker.push_arg_string("")
        native_invoker.push_arg_bool(true)
        native_invoker.push_arg_int(-1)
        native_invoker.push_arg_int(-1)
        native_invoker.push_arg_string(l1)
        native_invoker.push_arg_int(0)
        native_invoker.push_arg_bool(true)
        native_invoker.push_arg_int(0)
        native_invoker.end_call("701919482C74B5AB")
        util.yield()
    end
end

local function request_model(hash, timeout)
    timeout = timeout or 3
    STREAMING.REQUEST_MODEL(hash)
    local end_time = os.time() + timeout
    repeat
        util.yield()
    until STREAMING.HAS_MODEL_LOADED(hash) or os.time() >= end_time
    return STREAMING.HAS_MODEL_LOADED(hash)
end

local All_business_properties = {
    -- Clubhouses
    "罗伊洛文斯坦大道 1334 号",
    "佩罗海滩 7 号",
    "艾尔金大街 75 号",
    "68 号公路 101 号",
    "佩立托大道 1 号",
    "阿尔冈琴大道 47 号",
    "资本大道 137 号",
    "克林顿大街 2214 号",
    "霍伊克大街 1778 号",
    "东约书亚路 2111 号",
    "佩立托大道 68 号",
    "戈马街 4 号",
    -- 设施
    "塞诺拉大沙漠设施",
    "68 号公路设施",
    "沙滩海岸设施",
    "戈多山设施",
    "佩立托湾设施",
    "桑库多湖设施",
    "桑库多河设施",
    "荣恩风力发电场设施",
    "兰艾水库设施",
    -- 游戏厅
    "像素彼得 - 佩立托湾",
    "奇迹神所 - 葡萄籽",
    "仓库 - 戴维斯",
    "八位元 - 好麦坞",
    "请投币 - 罗克福德山",
    "游戏末日 - 梅萨",
}
local small_warehouses = {
    [1] = "太平洋鱼饵仓储",
    [2] = "白寡妇车库",
    [3] = "赛尔托瓦单元",
    [4] = "便利店车库",
    [5] = "法拍车库",
    [9] = "码头 400 号工作仓库",
}

local medium_warehouses = {
    [7] = "翘臀内衣外景场地",
    [10] = "GEE 仓库",
    [11] = "洛圣都海事大厦 3 号楼",
    [12] = "火车站仓库",
    [13] = "透心凉辅楼仓库",
    [14] = "废弃的工厂直销店",
    [15] = "折扣零售商店",
    [21] = "旧发电站",
}

local large_warehouses = {
    [6] = "希罗汽油工厂",
    [8] = "贝尔吉科仓库",
    [16] = "物流仓库",
    [17] = "达内尔兄弟仓库",
    [18] = "家具批发市场",
    [19] = "柏树仓库",
    [20] = "西好麦坞外景场地",
    [22] = "沃克父子仓库"
}

local weapon_stuff = {
    { "烟花", "weapon_firework" },
    { "原子能枪", "weapon_raypistol" },
    { "邪恶冥王", "weapon_raycarbine" },
    { "电磁步枪", "weapon_railgun" },
    { "红色激光", "vehicle_weapon_enemy_laser" },
    { "绿色激光", "vehicle_weapon_player_laser" },
    { "天煞机炮", "vehicle_weapon_player_lazer" },
    { "火箭炮", "weapon_rpg" },
    { "制导火箭发射器", "weapon_hominglauncher" },
    { "紧凑型电磁脉冲发射器", "weapon_emplauncher" },
    { "信号弹", "weapon_flaregun" },
    { "霰弹枪", "weapon_bullpupshotgun" },
    { "电击枪", "weapon_stungun" },
    { "催泪瓦斯", "weapon_smokegrenade" },
}

local proofs = {
    bullet = { name = "子弹", on = false },
    fire = { name = "火烧", on = false },
    explosion = { name = "爆炸", on = false },
    collision = { name = "撞击", on = false },
    melee = { name = "近战", on = false },
    steam = { name = "蒸汽", on = false },
    drown = { name = "溺水", on = false },
}

local effect_stuff = {
    { "吸毒驾车", "DrugsDrivingIn" },
    { "吸毒的崔佛", "DrugsTrevorClownsFight" },
    { "吸毒的麦克", "DrugsMichaelAliensFight" },
    { "小查视角(红绿色盲)", "ChopVision" },
    { "默片", "DeathFailOut" },
    { "黑白", "HeistCelebPassBW" },
    { "横冲直撞", "Rampage" },
    { "我的眼镜在哪里？", "MenuMGSelectionIn" },
    { "梦境", "DMT_flight_intro" },
}

local visual_stuff = {
    { "提升亮度", "AmbientPush" },
    { "提升饱和度", "rply_saturation" },
    { "提升曝光度", "LostTimeFlash" },
    { "雾之夜", "casino_main_floor_heist" },
    { "更好的夜晚", "dlc_island_vault" },
    { "正常雾天", "Forest" },
    { "大雾天", "nervousRON_fog" },
    { "黄昏天", "MP_Arena_theme_evening" },
    { "暖色调", "mp_bkr_int01_garage" },
    { "死气沉沉", "MP_deathfail_night" },
    { "石化", "stoned" },
    { "水下", "underwater" },
}

local drugged_effects = {
    "药品 1",
    "药品 2",
    "药品 3",
    "药品 4",
    "药品 5",
    "药品 6",
    "药品 7",
    "药品 8",
}

local unreleased_vehicles = {
    "Kanjosj",
    "Postlude",
    "Rhinehart",
    "Tenf",
    "Tenf2",
    "Sentinel4",
    "Weevil2",
}

local modded_vehicles = {
    "dune2",
    "tractor",
    "dilettante2",
    "asea2",
    "cutter",
    "mesa2",
    "jet",
    "skylift",
    "policeold1",
    "policeold2",
    "armytrailer2",
    "towtruck",
    "towtruck2",
    "cargoplane",
}

local modded_weapons = {
    "weapon_railgun",
    "weapon_stungun",
    "weapon_digiscanner",
}

local interiors = {
    { "安全空间 [挂机室]", { x = -158.71494, y = -982.75885, z = 149.13135 } },
    { "酷刑室", { x = 147.170, y = -2201.804, z = 4.688 } },
    { "矿道", { x = -595.48505, y = 2086.4502, z = 131.38136 } },
    { "欧米茄车库", { x = 2330.2573, y = 2572.3005, z = 46.679367 } },
    { "末日任务服务器组", { x = 2155.077, y = 2920.9417, z = -81.075455 } },
    { "角色捏脸房间", { x = 402.91586, y = -998.5701, z = -99.004074 } },
    { "Lifeinvader大楼", { x = -1082.8595, y = -254.774, z = 37.763317 } },
    { "竞速结束车库", { x = 405.9228, y = -954.1149, z = -99.6627 } },
    { "被摧毁的医院", { x = 304.03894, y = -590.3037, z = 43.291893 } },
    { "体育场", { x = -256.92334, y = -2024.9717, z = 30.145584 } },
    { "Split Sides喜剧俱乐部", { x = -430.00974, y = 261.3437, z = 83.00648 } },
    { "巴哈马酒吧", { x = -1394.8816, y = -599.7526, z = 30.319544 } },
    { "看门人之家", { x = -110.20285, y = -8.6156025, z = 70.51957 } },
    { "费蓝德医生之家", { x = -1913.8342, y = -574.5799, z = 11.435149 } },
    { "杜根房子", { x = 1395.2512, y = 1141.6833, z = 114.63437 } },
    { "弗洛伊德公寓", { x = -1156.5099, y = -1519.0894, z = 10.632717 } },
    { "麦克家", { x = -813.8814, y = 179.07889, z = 72.15914 } },
    { "富兰克林家（旧）", { x = -14.239959, y = -1439.6913, z = 31.101551 } },
    { "富兰克林家（新）", { x = 7.3125067, y = 537.3615, z = 176.02803 } },
    { "崔佛家", { x = 1974.1617, y = 3819.032, z = 33.436287 } },
    { "莱斯斯家", { x = 1273.898, y = -1719.304, z = 54.771 } },
    { "莱斯特的纺织厂", { x = 713.5684, y = -963.64795, z = 30.39534 } },
    { "莱斯特的纺织厂办事处", { x = 707.2138, y = -965.5549, z = 30.412853 } },
    { "甲基安非他明实验室", { x = 1391.773, y = 3608.716, z = 38.942 } },
    { "人道实验室", { x = 3625.743, y = 3743.653, z = 28.69009 } },
    { "汽车旅馆客房", { x = 152.2605, y = -1004.471, z = -99.024 } },
    { "警察局", { x = 443.4068, y = -983.256, z = 30.689589 } },
    { "太平洋标准银行金库", { x = 263.39627, y = 214.39891, z = 101.68336 } },
    { "布莱恩郡银行", { x = -109.77874, y = 6464.8945, z = 31.626724 } }, -- credit to fluidware for telling me about this one
    { "龙舌兰酒吧", { x = -564.4645, y = 275.5777, z = 83.074585 } },
    { "废料厂车库", { x = 485.46396, y = -1315.0614, z = 29.2141 } },
    { "失落摩托帮", { x = 980.8098, y = -101.96038, z = 74.84504 } },
    { "范吉利科珠宝店", { x = -629.9367, y = -236.41296, z = 38.057056 } },
    { "机场休息室", { x = -913.8656, y = -2527.106, z = 36.331566 } },
    { "停尸房", { x = 240.94368, y = -1379.0645, z = 33.74177 } },
    { "联盟保存处", { x = 1.298771, y = -700.96967, z = 16.131021 } },
    { "军事基地瞭望塔", { x = -2357.9187, y = 3249.689, z = 101.45073 } },
    { "事务所内部", { x = -1118.0181, y = -77.93254, z = -98.99977 } },
    { "中介所车库", { x = -1071.0494, y = -71.898506, z = -94.59982 } },
    { "复仇者内部", { x = 518.6444, y = 4750.4644, z = -69.3235 } },
    { "恐霸内部", { x = -1421.015, y = -3012.587, z = -80.000 } },
    { "地堡内部", { x = 899.5518, y = -3246.038, z = -98.04907 } },
    { "IAA 办公室", { x = 128.20, y = -617.39, z = 206.04 } },
    { "FIB 顶层", { x = 135.94359, y = -749.4102, z = 258.152 } },
    { "FIB 47层", { x = 134.5835, y = -766.486, z = 234.152 } },
    { "FIB 49层", { x = 134.635, y = -765.831, z = 242.152 } },
    { "大公鸡", { x = -31.007448, y = 6317.047, z = 40.04039 } },
    { "大麻商店", { x = -1170.3048, y = -1570.8246, z = 4.663622 } },
    { "脱衣舞俱乐部DJ位置", { x = 121.398254, y = -1281.0024, z = 29.480522 } },
}

local values = {
    [0] = 0,
    [1] = 50,
    [2] = 88,
    [3] = 160,
    [4] = 208,
}

local launch_vehicle = { "向上", "向前", "向后", "向下", "翻滚" }
local invites = { "游艇", "办公室", "会所", "办公室车库", "载具改装铺", "公寓" }
local style_names = { "正常", "半冲刺", "反向", "无视红绿灯", "避开交通", "极度避开交通", "有时超车" }
local drivingStyles = { 786603, 1074528293, 8388614, 1076, 2883621, 786468, 262144, 786469, 512, 5, 6 }
local interior_stuff = { 0, 233985, 169473, 169729, 169985, 170241, 177665, 177409, 185089, 184833, 184577, 163585, 167425, 167169 }

local self = menu.list(menu.my_root(), "自我选项", {}, "")
local players_list = menu.list(menu.my_root(), "玩家选项", {}, "")
local vehicle = menu.list(menu.my_root(), "载具选项", {}, "")
local session = menu.list(menu.my_root(), "聊天选项", {}, "")
local visuals = menu.list(menu.my_root(), "视觉效果", {}, "")
local funfeatures = menu.list(menu.my_root(), "娱乐功能", {}, "")
local teleport = menu.list(menu.my_root(), "传送选项", {}, "")
local detections = menu.list(menu.my_root(), "作弊检测", {}, "")
local bailOnAdminJoin = false
local protections = menu.list(menu.my_root(), "保护选项", {}, "")
menu.toggle(protections, "R*开发人员加入反应", {}, "", function(on)
    bailOnAdminJoin = on
end)

local int_min = -2147483647
local int_max = 2147483647

local spoofedrid = menu.ref_by_path("Online>Spoofing>RID Spoofing>Spoofed RID")
local spoofer = menu.ref_by_path("Online>Spoofing>RID Spoofing>RID Spoofing")
util.create_tick_handler(function()
    if menu.get_value(spoofedrid) == tostring(0xCB2A48C) and menu.get_value(spoofer) then
        util.toast("你个傻子...")
        menu.trigger_commands("forcequit")
        menu.set_value(spoofer, false)
    end
end)

if menu.get_value(spoofer) then
    menu.set_value(spoofer, false)
    ChangedThisSettings = true
end

local stinkers = { 0x919B57F }
for _, certified_bozo in ipairs(stinkers) do
    if players.get_rockstar_id(players.user()) == certified_bozo then
        menu.trigger_commands("forcequit")
    end
end

if ChangedThisSettings then
    ChangedThisSettings = nil
    menu.set_value(spoofer, true)
end

local menus = {}
local function player_list(pid)
    menus[pid] = menu.action(players_list, players.get_name(pid), {}, "", function()
        -- thanks to dangerman and aaron for showing me how to delete players properly
        menu.trigger_commands("jinxscript " .. players.get_name(pid))
    end)
end

local function handle_player_list(pid)
    local ref = menus[pid]
    if not players.exists(pid) then
        if ref then
            menu.delete(ref)
            menus[pid] = nil
        end
    end
end

players.on_join(player_list)
players.on_leave(handle_player_list)

local function player(pid)

    if pid ~= players.user() and players.get_rockstar_id(pid) == 0xCB2A48C then
        util.toast(lang.get_string(0xD251C4AA, lang.get_current()):gsub("{(.-)}", { player = players.get_name(pid), reason = "JinxScript Developer \n(They might be a sussy impostor, watch out!)" }), TOAST_DEFAULT)
    end

    if pid ~= players.user() and players.get_rockstar_id(pid) == 0xAE8F8C2 then
        util.toast(lang.get_string(0xD251C4AA, lang.get_current()):gsub("{(.-)}", { player = players.get_name(pid), reason = "Based Gigachad\n (They are very based! Proceed with caution!)" }), TOAST_DEFAULT)
    end

    menu.divider(menu.player_root(pid), "Jinx Script")
    local bozo = menu.list(menu.player_root(pid), "Jinx Script", { "JinxScript" }, "\n· 点击打开尊贵的Jinx脚本玩家选项\n· 免费的大爹级原创综合脚本\n· Jinx作者：Prisuhm\n")

    local friendly = menu.list(bozo, "友好", {}, "")
    menu.toggle_loop(friendly, "给予无敌隐形载具", {}, "不会被大多数菜单检测到载具无敌", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(ped), true, true, true, true, true, false, false, true)
    end, function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(ped), false, false, false, false, false, false, false, false)

    end)

    menu.action(friendly, "给他/她升升级", {}, "给予该玩家17万RP经验,可从1级提升至25级.\n一名玩家只能用一次嗷", function()
        util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x5, 0, 1, 1, 1 })
        for i = 0, 9 do
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x0, i, 1, 1, 1 })
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x1, i, 1, 1, 1 })
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x3, i, 1, 1, 1 })
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0xA, i, 1, 1, 1 })
        end
        for i = 0, 1 do
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x2, i, 1, 1, 1 })
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x6, i, 1, 1, 1 })
        end
        for i = 0, 19 do
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x4, i, 1, 1, 1 })
        end
        for i = 0, 99 do
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x9, i, 1, 1, 1 })
            util.yield()
        end
    end)

    local halloween_loop = menu.list(friendly, "循环给予万圣节收藏品", {}, "")
    local halloween_delay = 500
    menu.slider(halloween_loop, "延迟", {}, "", 0, 2500, 500, 10, function(amount)
        halloween_delay = amount
    end)
    player_toggle_loop(halloween_loop, pid, "启用循环", {}, "应该给他们不少钱和其他一些东西", function()
        util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x8, -1, 1, 1, 1 })
        util.yield(halloween_delay)
    end)

    local rpwarning
    rpwarning = menu.action(friendly, "循环给予经验收藏品", {}, "", function(click_type)
        menu.show_warning(rpwarning, click_type, "警告:这可能会导致封禁,后果自负.", function()
            local rp_loop = menu.list(friendly, "循环给予收藏品", {}, "")
            menu.delete(rpwarning)
            local rp_delay = 500
            menu.slider(rp_loop, "延迟", { "givedelay" }, "", 0, 2500, 500, 10, function(amount)
                rp_delay = amount
            end)

            menu.toggle_loop(rp_loop, "启用循环", {}, "每个收藏品会给玩家1000RP经验", function()
                util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x4, -1, 1, 1, 1 })
                util.yield(rp_delay)
            end)
            menu.trigger_command(rp_loop)
        end)
    end)

    local player_jinx_army = {}
    local army_player = menu.list(friendly, "宠物猫Jinx军队", {}, "整点小猫哄着你玩玩?\n删不掉的时候觉得烦的话换战局\n能少生成就少生成吧")
    menu.click_slider(army_player, "生成宠物猫Jinx军队", {}, "", 1, 256, 30, 1, function(val)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        pos.y = pos.y - 5
        pos.z = pos.z + 1
        local jinx = util.joaat("a_c_cat_01")
        request_model(jinx)
        for i = 1, val do
            player_jinx_army[i] = entities.create_ped(28, jinx, pos, 0)
            ENTITY.SET_ENTITY_INVINCIBLE(player_jinx_army[i], true)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(player_jinx_army[i], true)
            PED.SET_PED_COMPONENT_VARIATION(player_jinx_army[i], 0, 0, 1, 0)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(player_jinx_army[i], ped, 0, -0.3, 0, 7.0, -1, 10, true)
            util.yield()
        end
    end)

    menu.action(army_player, "清除Jinx宠物猫", {}, "有几只清不掉的时候你就傻了 嘿嘿\n追着你喵喵叫 嘿嘿", function()
        for _, ped in ipairs(entities.get_all_peds_as_handles()) do
            if PED.IS_PED_MODEL(ped, util.joaat("a_c_cat_01")) then
                entities.delete_by_handle(ped)
            end
        end
    end)

    local funfeatures_player = menu.list(bozo, "娱乐", {}, "")
    menu.action(funfeatures_player, "自定义短信通知", { "customnotify" }, "例如: ~q~ <FONT SIZE=\"35\"> JINX SCRIPT ON TOP~", function(cl)
        menu.show_command_box_click_based(cl, "customnotify " .. players.get_name(pid):lower() .. " ")
    end, function(input)
        local event_data = { 0x8E38E2DF, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
        input = input:sub(1, 127)
        for i = 0, #input - 1 do
            local slot = i // 8
            local byte = string.byte(input, i + 1)
            event_data[slot + 3] = event_data[slot + 3] | byte << ((i - slot * 8) * 8)
        end
        util.trigger_script_event(1 << pid, event_data)
    end)

    menu.action(funfeatures_player, "自定义短信标签", { "label" }, "", function()
        menu.show_command_box("label " .. players.get_name(pid) .. " ")
    end, function(label)
        local event_data = { 0xD0CCAC62, players.user(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
        local out = label:sub(1, 127)
        if HUD.DOES_TEXT_LABEL_EXIST(label) then
            for i = 0, #out - 1 do
                local slot = i // 8
                local byte = string.byte(out, i + 1)
                event_data[slot + 3] = event_data[slot + 3] | byte << ((i - slot * 8) * 8)
            end
            util.trigger_script_event(1 << pid, event_data)
        else
            util.toast("抱歉,这不是一个有效的标签. :/")
        end
    end)

    menu.hyperlink(funfeatures_player, "列表标签", "https://gist.githubusercontent.com/aaronlink127/afc889be7d52146a76bab72ede0512c7/raw")

    local trolling = menu.list(bozo, "恶搞选项", {}, "")
    player_toggle_loop(trolling, pid, "将玩家推向前方", {}, "", function()
        local glitch_hash = util.joaat("prop_shuttering03")
        request_model(glitch_hash)
        local dumb_object_front = entities.create_object(glitch_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 1, 0))
        local dumb_object_back = entities.create_object(glitch_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 0, 0))
        ENTITY.SET_ENTITY_VISIBLE(dumb_object_front, false)
        ENTITY.SET_ENTITY_VISIBLE(dumb_object_back, false)
        util.yield()
        entities.delete_by_handle(dumb_object_front)
        entities.delete_by_handle(dumb_object_back)
        util.yield()
    end)

    local glitch_player_list = menu.list(trolling, "鬼畜玩家", { "glitchdelay" }, "")
    local object_stuff = {
        names = {
            "摩天轮",
            "UFO",
            "水泥搅拌车",
            "脚手架",
            "车库门",
            "保龄球",
            "足球",
            "橘子",
            "特技坡道",

        },
        objects = {
            "prop_ld_ferris_wheel",
            "p_spinning_anus_s",
            "prop_staticmixer_01",
            "prop_towercrane_02a",
            "des_scaffolding_root",
            "prop_sm1_11_garaged",
            "stt_prop_stunt_bowling_ball",
            "stt_prop_stunt_soccer_ball",
            "prop_juicestand",
            "stt_prop_stunt_jump_l",
        }
    }

    local object_hash = util.joaat("prop_ld_ferris_wheel")
    menu.list_select(glitch_player_list, "物体", { "glitchplayer" }, "选择鬼畜玩家使用的物体.", object_stuff.names, 1, function(index)
        object_hash = util.joaat(object_stuff.objects[index])
    end)

    menu.slider(glitch_player_list, "物体生成延迟", { "spawndelay" }, "", 0, 3000, 50, 10, function(amount)
        delay = amount
    end)

    local glitchPlayer = false
    local glitchPlayer_toggle
    glitchPlayer_toggle = menu.toggle(glitch_player_list, "启用", {}, "", function(toggled)
        glitchPlayer = toggled

        while glitchPlayer do
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
            if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 1000.0
                    and v3.distance(pos, players.get_cam_pos(players.user())) > 1000.0 then
                util.toast("这傻逼超出你的范围了 没法整. :/")
                menu.set_value(glitchPlayer_toggle, false);
                break
            end

            if not players.exists(pid) then
                util.toast("找不到这傻逼,看看他还在战局吗?")
                menu.set_value(glitchPlayer_toggle, false);
                break
            end
            local glitch_hash = object_hash
            local poopy_butt = util.joaat("rallytruck")
            request_model(glitch_hash)
            request_model(poopy_butt)
            local stupid_object = entities.create_object(glitch_hash, pos)
            local glitch_vehicle = entities.create_vehicle(poopy_butt, pos, 0)
            ENTITY.SET_ENTITY_VISIBLE(stupid_object, false)
            ENTITY.SET_ENTITY_VISIBLE(glitch_vehicle, false)
            ENTITY.SET_ENTITY_INVINCIBLE(stupid_object, true)
            ENTITY.SET_ENTITY_COLLISION(stupid_object, true, true)
            ENTITY.APPLY_FORCE_TO_ENTITY(glitch_vehicle, 1, 0.0, 10, 10, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            util.yield(delay)
            entities.delete_by_handle(stupid_object)
            entities.delete_by_handle(glitch_vehicle)
            util.yield(delay)
        end
    end)

    local glitchVeh = false
    local glitchVehCmd
    glitchVehCmd = menu.toggle(trolling, "鬼畜载具", { "glitchvehicle" }, "", function(toggle)
        -- credits to soul reaper for base concept
        glitchVeh = toggle
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local player_veh = PED.GET_VEHICLE_PED_IS_USING(ped)
        local veh_model = players.get_vehicle_model(pid)
        local ped_hash = util.joaat("a_m_m_acult_01")
        local object_hash = util.joaat("prop_ld_ferris_wheel")
        request_model(ped_hash)
        request_model(object_hash)

        while glitchVeh do
            if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 1000.0
                    and v3.distance(pos, players.get_cam_pos(players.user())) > 1000.0 then
                util.toast("Player is out of rendering distance. :/")
                menu.set_value(glitchVehCmd, false);
                break
            end

            if not players.exists(pid) then
                util.toast("找不到这傻逼,看看他还在战局吗?")
                menu.set_value(glitchVehCmd, false);
                break
            end

            if not PED.IS_PED_IN_VEHICLE(ped, player_veh, false) then
                util.toast("你瞎吗?他不在车里啊! ")
                menu.set_value(glitchVehCmd, false);
                break
            end

            if not VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(player_veh) then
                util.toast("车上没空座位了\n建议你给他车砸了.")
                menu.set_value(glitchVehCmd, false);
                break
            end

            local seat_count = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(veh_model)
            local glitch_obj = entities.create_object(object_hash, pos)
            local glitched_ped = entities.create_ped(26, ped_hash, pos, 0)
            local things = { glitched_ped, glitch_obj }

            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(glitch_obj)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(glitched_ped)

            ENTITY.ATTACH_ENTITY_TO_ENTITY(glitch_obj, glitched_ped, 0, 0, 0, 0, 0, 0, 0, true, true, false, 0, true)

            for _, spawned_objects in ipairs(things) do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(spawned_objects)
                ENTITY.SET_ENTITY_VISIBLE(spawned_objects, false)
                ENTITY.SET_ENTITY_INVINCIBLE(spawned_objects, true)
            end

            for i = 0, seat_count - 1 do
                if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(player_veh) then
                    local emptyseat = i
                    for _ = 1, 25 do
                        PED.SET_PED_INTO_VEHICLE(glitched_ped, player_veh, emptyseat)
                        ENTITY.SET_ENTITY_COLLISION(glitch_obj, true, true)
                        util.yield()
                    end
                end
            end

            if not menu.get_value(glitchVehCmd) then
                entities.delete_by_handle(glitched_ped)
                entities.delete_by_handle(glitch_obj)
            end
            if glitched_ped ~= nil then
                -- added a 2nd stage here because it didnt want to delete sometimes, this solved that lol.
                entities.delete_by_handle(glitched_ped)
            end
            if glitch_obj ~= nil then
                entities.delete_by_handle(glitch_obj)
            end
        end
    end)

    local glitchForcefield = false
    local glitchforcefield_toggle
    glitchforcefield_toggle = menu.toggle(trolling, "大范围立场", { "forcefield" }, "", function(toggled)
        glitchForcefield = toggled
        local glitch_hash = util.joaat("p_spinning_anus_s")
        request_model(glitch_hash)

        while glitchForcefield do
            if not players.exists(pid) then
                util.toast("找不到这傻逼,看看他还在战局吗?")
                menu.set_value(glitchPlayer_toggle, false);
                break
            end

            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local playerpos = ENTITY.GET_ENTITY_COORDS(ped, false)

            if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                util.toast("需要他在车里.")
                menu.set_value(glitchforcefield_toggle, false);
                break
            end

            local stupid_object = entities.create_object(glitch_hash, playerpos)
            ENTITY.SET_ENTITY_VISIBLE(stupid_object, false)
            ENTITY.SET_ENTITY_INVINCIBLE(stupid_object, true)
            ENTITY.SET_ENTITY_COLLISION(stupid_object, true, true)
            util.yield()
            entities.delete_by_handle(stupid_object)
            util.yield()
        end
    end)

    player_toggle_loop(trolling, pid, "弹飞玩家", {}, "也适用于载具", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        pos.z -= 10
        request_model(poopy_butt)
        local poopy_vehicle = entities.create_vehicle(poopy_butt, pos, 0)
        ENTITY.SET_ENTITY_VISIBLE(poopy_vehicle, false)
        util.yield(250)
        if poopy_vehicle ~= 0 then
        ENTITY.APPLY_FORCE_TO_ENTITY(poopy_vehicle, 1, 0.0, 0.0, 75.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
        util.yield(250)
        entities.delete_by_handle(poopy_vehicle)
        end
    end)

    local freeze = menu.list(trolling, "冻结", {}, "冻住之后想想办法干他屁眼")
    player_toggle_loop(freeze, pid, "暴力冻结", {}, "", function()
        util.trigger_script_event(1 << pid, { 0x4868BC31, pid, 0, 0, 0, 0, 0 })
        util.yield(500)
    end)

    player_toggle_loop(freeze, pid, "仓库冻结", {}, "", function()
        util.trigger_script_event(1 << pid, { 0x7EFC3716, pid, 0, 1, 0, 0 })
        util.yield(500)
    end)

    player_toggle_loop(freeze, pid, "模型冻结", {}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    end)

    local inf_loading = menu.list(trolling, "无限加载屏幕", {}, "\n你可真不是个人\n禁止使用该功能欺负绿玩\n我觉得你可以尝试使用《绿玩保护崩溃》\n")
    menu.action(inf_loading, "传送邀请", {}, "", function()
        util.trigger_script_event(1 << pid, { 0xDEE5ED91, pid, 0, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
    end)

    menu.action(inf_loading, "公寓邀请", {}, "", function()
        util.trigger_script_event(1 << pid, { 0x7EFC3716, pid, 0, 1, id })
    end)

    menu.action_slider(inf_loading, "资产邀请", {}, "单击以选择样式", invites, function(_, name)
        pluto_switch
        name
        do
            case
            1   :
            util.trigger_script_event
            (1 << pid, {0x4246AA25, pid, 0x1})
        util.toast("游艇邀请已发送")
        break
        case 2:
        util.trigger_script_event(1 << pid, {0x4246AA25, pid, 0x2})
        util.toast("办公室邀请已发送")
        break
        case 3:
        util.trigger_script_event(1 << pid, {0x4246AA25, pid, 0x3})
        util.toast("会所邀请已发送")
        break
        case 4:
        util.trigger_script_event(1 << pid, {0x4246AA25, pid, 0x4})
        util.toast("办公室车库邀请已发送")
        break
        case 5:
        util.trigger_script_event(1 << pid, {0x4246AA25, pid, 0x5})
        util.toast("载具改装铺邀请已发送")
        break
        case 6:
        util.trigger_script_event(1 << pid, {0x4246AA25, pid, 0x6})
            util.toast("公寓邀请已发送")
            break
        end
    end)

    player_toggle_loop(trolling, pid, "使该玩家黑屏", { "blackscreen" }, "\n你可真不是个人\n禁止使用该功能欺负绿玩\n我觉得你可以尝试使用《绿玩保护崩溃》\n", function()
        util.trigger_script_event(1 << pid, { 0xDEE5ED91, pid, math.random(1, 0x20), 0x20, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
        util.yield(1000)
    end)

    local cage = menu.list(trolling, "困住玩家", {}, "")
    menu.action(cage, "电击笼子", { "electriccage" }, "你确定你要当雷电法王杨永信吗?\n做个人吧!", function(_)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        pos.z -= 0.5
        request_model(elec_box)
        local temp_v3 = v3.new(0, 0, 0)
        for i = 1, number_of_cages do
        local angle = (i / number_of_cages) * 360
        temp_v3.z = angle
        local obj_pos = temp_v3:toDir()
        obj_pos:mul(2.5)
        obj_pos:add(pos)
        for offs_z = 1, 5 do
        local electric_cage = entities.create_object(elec_box, obj_pos)
        spawned_objects[#spawned_objects + 1] = electric_cage
        ENTITY.SET_ENTITY_ROTATION(electric_cage, 90.0, 0.0, angle, 2, 0)
        obj_pos.z + = 0.75
        ENTITY.FREEZE_ENTITY_POSITION(electric_cage, true)
        end
        end
    end)
    menu.action(cage, "英国女王笼子", { "" }, "也叫伊丽莎白笼子&安倍晋三笼子", function(_)
        local number_of_cages = 6
        local coffin_hash = util.joaat("prop_coffin_02b")
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        request_model(coffin_hash)
        local temp_v3 = v3.new(0, 0, 0)
        for i = 1, number_of_cages do
            local angle = (i / number_of_cages) * 360
            temp_v3.z = angle
            local obj_pos = temp_v3:toDir()
            obj_pos:mul(0.8)
            obj_pos:add(pos)
            obj_pos.z += 0.1
        local coffin = entities.create_object(coffin_hash, obj_pos)
        spawned_objects[#spawned_objects + 1] = coffin
        ENTITY.SET_ENTITY_ROTATION(coffin, 90.0, 0.0, angle, 2, 0)
        ENTITY.FREEZE_ENTITY_POSITION(coffin, true)
        end
    end)

    menu.action(cage, "集装箱笼子", { "cage" }, "", function()
        local container_hash = util.joaat("prop_container_ld_pu")
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        request_model(container_hash)
        pos.z -= 1
        local container = entities.create_object(container_hash, pos, 0)
        spawned_objects[#spawned_objects + 1] = container
        ENTITY.FREEZE_ENTITY_POSITION(container, true)
    end)

    menu.action(cage, "瓦斯笼子", { "gascage" }, "", function()
        local gas_cage_hash = util.joaat("prop_gascage01")
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        request_model(gas_cage_hash)
        pos.z -= 1
        local gas_cage = entities.create_object(gas_cage_hash, pos, 0)
        pos.z + = 1
        local gas_cage2 = entities.create_object(gas_cage_hash, pos, 0)
        spawned_objects[#spawned_objects + 1] = gas_cage
        spawned_objects[#spawned_objects + 1] = gas_cage2
        ENTITY.FREEZE_ENTITY_POSITION(gas_cage, true)
        ENTITY.FREEZE_ENTITY_POSITION(gas_cage2, true)
    end)

    menu.action(cage, "删除所有生成的笼子", { "clearcages" }, "", function()
        local entitycount = 0
        for i, object in ipairs(spawned_objects) do
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(object, false, false)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(object)
            entities.delete_by_handle(object)
            spawned_objects[i] = nil
            entitycount += 1
        end
        util.toast("删除了 " .. entitycount .. "个已生成的笼子")
    end)

    menu.action(trolling, "攀爬梯子", { "" }, "", function(_)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        pos.z -= 0.5
        request_model(ladder_hash)

        if TASK.IS_PED_STILL(ped) then
        util.toast("干他妈的.这傻逼不动. :/")
        return end

        local temp_v3 = v3.new(0, 0, 0)
        for i = 1, number_of_cages do
        local angle = (i / number_of_cages) * 360
        temp_v3.z = angle
        local obj_pos = temp_v3:toDir()
        obj_pos:mul(0.25)
        obj_pos:add(pos)
        local ladder = entities.create_object(ladder_hash, obj_pos)
        ladder_objects[#ladder_objects + 1] = ladder
        ENTITY.SET_ENTITY_VISIBLE(ladder, false)
        ENTITY.SET_ENTITY_ROTATION(ladder, 0.0, 0.0, angle, 2, 0)
        ENTITY.FREEZE_ENTITY_POSITION(ladder, true)
        end
        util.yield(2500)
        for i, object in ipairs(ladder_objects) do
        entities.delete_by_handle(object)
        end
    end)

    menu.click_slider(trolling, "虚假抢钱", {}, "", 0, 2000000000, 0, 1000, function(amount)
        util.trigger_script_event(1 << pid, { 0xA4D43510, players.user(), 0xB2B6334F, amount, 0, 0, 0, 0, 0, 0, pid, players.user(), 0, 0 })
        util.trigger_script_event(1 << players.user(), { 0xA4D43510, players.user(), 0xB2B6334F, amount, 0, 0, 0, 0, 0, 0, pid, players.user(), 0, 0 })
    end)

    menu.action(trolling, "杀死室内玩家", {}, "这崽种不在公寓里则没法使用\n你可以尝试用公寓邀请给他拉到一个公寓\n再来试试这个功能", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)

        for _, interior in ipairs(interior_stuff) do
            if get_interior_player_is_in(pid) == interior then
                util.toast("这崽种不在家啊，求求你回去看提示:/")
                return
            end
            if get_interior_player_is_in(pid) ~= interior then
                util.trigger_script_event(1 << pid, { 0xAD36AA57, pid, 0x96EDB12F, math.random(0, 0x270F) })
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 1000, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
            end
        end
    end)

    player_toggle_loop(trolling, pid, "电死这个杂种", {}, "来自雷电法王杨永信的电疗\n拯救网瘾少年的任务就交给你了", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        for _ = 1, 50 do
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 0, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
        end
        util.yield(100)
    end)

    menu.action(trolling, "给这傻逼送进监狱", {}, "", function()
        local my_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
        local my_ped = PLAYER.GET_PLAYER_PED(players.user())
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my_ped, 1628.5234, 2570.5613, 45.56485, true, false, false, false)
        menu.trigger_commands("givesh " .. players.get_name(pid))
        menu.trigger_commands("summon " .. players.get_name(pid))
        menu.trigger_commands("invisibility on")
        menu.trigger_commands("otr")
        util.yield(5000)
        menu.trigger_commands("invisibility off")
        menu.trigger_commands("otr")
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my_ped, my_pos)
    end)

    menu.action_slider(trolling, "发射玩家载具", {}, "", launch_vehicle, function(_, value)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
        if not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            util.toast("玩家不在载具里. :/")
            return
        end

        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) do
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
            util.yield()
        end

        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
            util.toast("无法控制此玩家载具. :/")
            return
        end

        pluto_switch
        value
        do
            case "向上":
            ENTITY     .APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 100000.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            break
            case "向前":
            ENTITY     .APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 100000.0, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            break
            case "向后":
            ENTITY     .APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, -100000.0, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            break
            case "向下":
            ENTITY     .APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, -100000.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            break
            case "翻滚":
            ENTITY     .APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 100000.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 100000.0, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            break
        end
    end)

    player_toggle_loop(trolling, pid, "声音骚扰", {}, "你真贱\n不过我喜欢", function()
        util.trigger_script_event(1 << pid, { 0x4246AA25, pid, math.random(1, 0x6) })
        util.yield()
    end)

    menu.action(trolling, "强制室内黑屏", {}, "玩家必须在公寓里,可以通过重新加入战局来撤销", function(_)
        if is_player_in_interior(pid) then
            util.trigger_script_event(1 << pid, { 0xB031BD16, pid, pid, pid, pid, math.random(int_min, int_max), pid })
        else
            util.toast("玩家不在公寓里. :/")
        end
    end)

    menu.action(trolling, "警告玩家", {}, "化身神鹰黑手哥给他个警告", function()
        local radar = util.joaat("prop_air_bigradar")
        request_model(radar)

        local radar_dish = entities.create_object(radar, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 20, -3))
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(radar_dish)
        chat.send_message("你别让我抓着你，抓着你，我让你知道知道什么叫黑手，草你妈的。", false, true, true)
        util.yield(10000)
        entities.delete_by_handle(radar_dish)
    end)

    local antimodder = menu.list(bozo, "反作弊者", {}, "")
    local kill_godmode = menu.list(antimodder, "击杀无敌玩家", {}, "")
    menu.action(kill_godmode, "击杀无敌玩家", { "" }, "适用于小菜单", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 99999, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
    end)

    menu.slider_text(kill_godmode, "压死无敌玩家", {}, "嘎嘎好用 嘎嘎权威 强烈推荐", { "Khanjali", "APC" }, function(_, veh)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        local vehicle = util.joaat(veh)
        request_model(vehicle)

        pluto_switch
        veh
        do
            case "Khanjali":
            height = 2.8
            offset = 0
            break
            case "APC":
            height = 3.4
            offset = -1.5
            break
        end

        if TASK.IS_PED_STILL(ped) then
            distance = 0
        elseif not TASK.IS_PED_STILL(ped) then
            distance = 3
        end

        local vehicle1 = entities.create_vehicle(vehicle, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), offset, distance, height), ENTITY.GET_ENTITY_HEADING(ped))
        local vehicle2 = entities.create_vehicle(vehicle, pos, 0)
        local vehicle3 = entities.create_vehicle(vehicle, pos, 0)
        local vehicle4 = entities.create_vehicle(vehicle, pos, 0)
        local spawned_vehs = { vehicle4, vehicle3, vehicle2, vehicle1 }
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle2, vehicle1, 0, 0, 3, 0, 0, 0, -180, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle3, vehicle1, 0, 3, 3, 0, 0, 0, -180, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle4, vehicle1, 0, 3, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
        ENTITY.SET_ENTITY_VISIBLE(vehicle1, false)
        util.yield(5000)
        for i = 1, #spawned_vehs do
            entities.delete_by_handle(spawned_vehs[i])
        end
    end)

    player_toggle_loop(kill_godmode, pid, "炸死无敌玩家", {}, "被大多数菜单拦截", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        if not PED.IS_PED_DEAD_OR_DYING(ped) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) then
            util.trigger_script_event(1 << pid, { 0xAD36AA57, pid, 0x96EDB12F, math.random(0, 0x270F) })
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos, 2, 50, true, false, 0.0)
        end
    end)

    player_toggle_loop(antimodder, pid, "移除玩家无敌", {}, "被大多数菜单拦截", function()
        util.trigger_script_event(1 << pid, { 0xAD36AA57, pid, 0x96EDB12F, math.random(0, 0x270F) })
    end)

    player_toggle_loop(antimodder, pid, "移除无敌玩家武器", {}, "被小部分菜单拦截", function()
        for _, pid in ipairs(players.list(true, true, true)) do
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(players.user(), ped) and players.is_godmode(pid) then
                util.trigger_script_event(1 << pid, { 0xAD36AA57, pid, 0x96EDB12F, math.random(0, 0x270F) })
            end
        end
    end)

    player_toggle_loop(antimodder, pid, "移除载具无敌", { "removevgm" }, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) and not PED.IS_PED_DEAD_OR_DYING(ped) then
            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, true)
            ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
            ENTITY.SET_ENTITY_PROOFS(veh, false, false, false, false, false, 0, 0, false)
        end
    end)

    local tp_player = menu.list(bozo, "传送玩家到", {}, "")
    local clubhouse = menu.list(tp_player, "摩托帮会所", {}, "")
    local facility = menu.list(tp_player, "设施", {}, "")
    local arcade = menu.list(tp_player, "游戏厅", {}, "")
    local warehouse = menu.list(tp_player, "仓库", {}, "")
    local cayoperico = menu.list(tp_player, "佩里科岛", {}, "")

    for id, name in pairs(All_business_properties) do
        if id <= 12 then
            menu.action(clubhouse, name, {}, "", function()
                util.trigger_script_event(1 << pid, { 0xDEE5ED91, pid, id, 0x20, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, math.random(1, 10) })
            end)
        elseif id > 12 and id <= 21 then
            menu.action(facility, name, {}, "", function()
                util.trigger_script_event(1 << pid, { 0xDEE5ED91, pid, id, 0x20, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
            end)
        elseif id > 21 then
            menu.action(arcade, name, {}, "", function()
                util.trigger_script_event(1 << pid, { 0xDEE5ED91, pid, id, 0x20, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 })
            end)
        end
    end

    local small = menu.list(warehouse, "小型仓库", {}, "")
    local medium = menu.list(warehouse, "中型仓库", {}, "")
    local large = menu.list(warehouse, "大型仓库", {}, "")

    for id, name in pairs(small_warehouses) do
        menu.action(small, name, {}, "", function()
            util.trigger_script_event(1 << pid, { 0x7EFC3716, pid, 0, 1, id })
        end)
    end

    for id, name in pairs(medium_warehouses) do
        menu.action(medium, name, {}, "", function()
            util.trigger_script_event(1 << pid, { 0x7EFC3716, pid, 0, 1, id })
        end)
    end

    for id, name in pairs(large_warehouses) do
        menu.action(large, name, {}, "", function()
            util.trigger_script_event(1 << pid, { 0x7EFC3716, pid, 0, 1, id })
        end)
    end

    menu.action(tp_player, "公寓邀请", {}, "", function()
        util.trigger_script_event(1 << pid, { 0xAD1762A7, players.user(), pid, -1, 1, 1, 0, 1, 0 })
    end)

    menu.action(cayoperico, "佩里科岛(有过场动画)", { "tpcayo" }, "", function()
        util.trigger_script_event(1 << pid, { 0x4868BC31, pid, 0, 0, 0x3, 1 })
    end)

    menu.action(cayoperico, "佩里科岛(无过场动画)", { "tpcayo2" }, "", function()
        util.trigger_script_event(1 << pid, { 0x4868BC31, pid, 0, 0, 0x4, 1 })
    end)

    menu.action(cayoperico, "离开佩里科岛", { "cayoleave" }, "玩家必须在佩里科岛才能触发此事件", function()
        util.trigger_script_event(1 << pid, { 0x4868BC31, pid, 0, 0, 0x3 })
    end)

    menu.action(cayoperico, "从佩里科岛踢出", { "cayokick" }, "", function()
        util.trigger_script_event(1 << pid, { 0x4868BC31, pid, 0, 0, 0x4, 0 })
    end)

    local player_removals = menu.list(bozo, "移除玩家", {}, "<崩溃>与<踢出>\nCrash&Kick")
    local crashes = menu.list(player_removals, "崩溃", {}, "犹豫不决时就选崩溃\n崩溃是你永远的家!")
    local kicks = menu.list(player_removals, "踢出", {}, "咱要实在崩不掉试试踢也行\n不丢人!!!")
    menu.action(kicks, "自由踢", { "freemodedeath" }, "送回故事模式", function()
        util.trigger_script_event(1 << pid, { 0x6A16C7F, pid, memory.script_global(0x2908D3 + 1 + (pid * 0x1C5) + 0x13E + 0x7) })
    end)

    menu.action(kicks, "网络保释踢", { "networkbail" }, "", function()
        util.trigger_script_event(1 << pid, { 0x63D4BFB1, players.user(), memory.read_int(memory.script_global(0x1CE15F + 1 + (pid * 0x257) + 0x1FE)) })
    end)

    menu.action(kicks, "无效掉落踢", { "invalidcollectible" }, "", function()
        util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x4, -1, 1, 1, 1 })
    end)

    if menu.get_edition() >= 2 then
        menu.action(kicks, "智能踢", { "adaptivekick" }, "", function()
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x4, -1, 1, 1, 1 })
            util.trigger_script_event(1 << pid, { 0x6A16C7F, pid, memory.script_global(0x2908D3 + 1 + (pid * 0x1C5) + 0x13E + 0x7) })
            util.trigger_script_event(1 << pid, { 0x63D4BFB1, players.user(), memory.read_int(memory.script_global(0x1CE15F + 1 + (pid * 0x257) + 0x1FE)) })
            menu.trigger_commands("breakdown" .. players.get_name(pid))
        end)
    else
        menu.action(kicks, "智能踢", { "adaptivekick" }, "", function()
            util.trigger_script_event(1 << pid, { 0xB9BA4D30, pid, 0x4, -1, 1, 1, 1 })
            util.trigger_script_event(1 << pid, { 0x6A16C7F, pid, memory.script_global(0x2908D3 + 1 + (pid * 0x1C5) + 0x13E + 0x7) })
            util.trigger_script_event(1 << pid, { 0x63D4BFB1, players.user(), memory.read_int(memory.script_global(0x1CE15F + 1 + (pid * 0x257) + 0x1FE)) })
        end)
    end

    if menu.get_edition() >= 2 then
        menu.action(kicks, "阻止加入踢", { "blast" }, "将该玩家踢出后加入到stand阻止加入的列表中.", function()
            menu.trigger_commands("historyblock " .. players.get_name(pid))
            menu.trigger_commands("breakdown" .. players.get_name(pid))
        end)
    end

    local nature = menu.list(crashes, "大自然崩溃", {}, "就是伞崩\n贴脸崩更好")
    menu.action(nature, "大自然崩溃 v1", { "nature" }, "被部分主流菜单拦截", function()
        local user = players.user()
        local user_ped = players.user_ped()
        local pos = players.get_position(user)
        BlockSyncs(pid, function()
            -- blocking outgoing syncs to prevent the lobby from crashing :5head:
            util.yield(100)
            menu.trigger_commands("invisibility on")
            for i = 0, 110 do
                PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user, 0xFBF7D21F)
                PED.SET_PED_COMPONENT_VARIATION(user_ped, 5, i, 0, 0)
                util.yield(50)
                PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user)
            end
            util.yield(250)
            for _ = 1, 5 do
                util.spoof_script("freemode", SYSTEM.WAIT) -- preventing wasted screen
            end
            ENTITY.SET_ENTITY_HEALTH(user_ped, 0) -- killing ped because it will still crash others until you die (clearing tasks doesnt seem to do much)
            NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(pos, 0, false, false, 0)
            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user)
            menu.trigger_commands("invisibility off")
        end)
    end)

    menu.action(nature, "大自然崩溃 v2", { "" }, "原广岛崩\n被部分主流菜单拦截\n个人感觉比V1好玩", function()
        local user = players.user()
        local user_ped = players.user_ped()
        local pos = players.get_position(user)
        BlockSyncs(pid, function()
            util.yield(100)
            PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user(), 0xFBF7D21F)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(user_ped, 0xFBAB5776, 100, false)
            TASK.TASK_PARACHUTE_TO_TARGET(user_ped, pos.x, pos.y, pos.z)
            util.yield()
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(user_ped)
            util.yield(250)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(user_ped, 0xFBAB5776, 100, false)
            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user)
            util.yield(1000)
            for _ = 1, 5 do
                util.spoof_script("freemode", SYSTEM.WAIT)
            end
            ENTITY.SET_ENTITY_HEALTH(user_ped, 0)
            NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(pos, 0, false, false, 0)
        end)
    end)

    menu.action(crashes, "绿玩保护崩溃", { "cps" }, "\n尽量不要靠得太近!\n拿来《保护》尊贵的绿色玩家\n", function()
        local mdl = util.joaat('a_c_poodle')
        BlockSyncs(pid, function()
            if request_model(mdl, 2) then
                util.yield(100)
                ped1 = entities.create_ped(26, mdl, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 3, 0), 0)

                local coords = ENTITY.GET_ENTITY_COORDS(ped1, true)
                WEAPON.GIVE_WEAPON_TO_PED(ped1, util.joaat('WEAPON_HOMINGLAUNCHER'), 9999, true, true)
                local obj
                repeat
                    obj = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(ped1, 0)
                until obj ~= 0 or util.yield()
                ENTITY.DETACH_ENTITY(obj, true, true)
                util.yield(1500)
                FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 0, 1.0, false, true, 0.0, false)
                entities.delete_by_handle(ped1)
                util.yield(1000)
            else
                util.toast("Failed to load model. :/")
            end
        end)
    end)

    menu.action(crashes, "泡泡糖崩溃", {}, "2.42改进版,不要连按否则可能造成自崩", function()
        local mdl = util.joaat("apa_mp_apa_yacht")
        local user = players.user_ped()
        BlockSyncs(pid, function()
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(user, 0xFBAB5776, 100, false)
            PLAYER.SET_PLAYER_HAS_RESERVE_PARACHUTE(players.user())
            PLAYER._SET_PLAYER_RESERVE_PARACHUTE_MODEL_OVERRIDE(players.user(), mdl)
            util.yield(50)
            local pos = players.get_position(pid)
            pos.z += 300
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(user)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(user, pos, false, false, false)
            repeat
            util.yield()
            until PED.GET_PED_PARACHUTE_STATE(user) == 0
            PED.FORCE_PED_TO_OPEN_PARACHUTE(user)
            util.yield(50)
            TASK.CLEAR_PED_TASKS(user)
            util.yield(50)
            PED.FORCE_PED_TO_OPEN_PARACHUTE(user)
            repeat
            util.yield()
            until PED.GET_PED_PARACHUTE_STATE(user) ~= 1
            pcall(TASK.CLEAR_PED_TASKS_IMMEDIATELY, user)
            PLAYER._CLEAR_PLAYER_RESERVE_PARACHUTE_MODEL_OVERRIDE(players.user())
            pcall(ENTITY.SET_ENTITY_COORDS, user, old_pos, false, false)
        end)
    end)

    menu.action(crashes, "莱纳斯崩溃", {}, "Jinx2.3版本增强改进", function()
        local int_min = -2147483647
        local int_max = 2147483647
        for _ = 1, 150 do
            util.trigger_script_event(1 << pid, { 2765370640, pid, 3747643341, math.random(int_min, int_max), math.random(int_min, int_max),
                                                  math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),
                                                  math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max) })
        end
        util.yield()
        for _ = 1, 15 do
            util.trigger_script_event(1 << pid, { 1348481963, pid, math.random(int_min, int_max) })
        end
        menu.trigger_commands("givesh " .. players.get_name(pid))
        util.yield(100)
        util.trigger_script_event(1 << pid, { 495813132, pid, 0, 0, -12988, -99097, 0 })
        util.trigger_script_event(1 << pid, { 495813132, pid, -4640169, 0, 0, 0, -36565476, -53105203 })
        util.trigger_script_event(1 << pid, { 495813132, pid, 0, 1, 23135423, 3, 3, 4, 827870001, 5, 2022580431, 6, -918761645, 7, 1754244778, 8, 827870001, 9, 17 })
    end)

    local krustykrab = menu.list(crashes, "蟹堡王崩溃", {}, "\n你闻到什么味道了吗？\n这味道是一种臭臭的味道\n这种臭臭的味道难道是.......\n\n                --蟹老板")

    local peds = 5
    menu.slider(krustykrab, "PED数量", {}, "", 1, 10, 5, 1, function(amount)
        peds = amount
    end)

    local crash_ents = {}
    local crash_toggle = false
    menu.toggle(krustykrab, "崩溃玩家", {}, "需要一些时间才可以完成，可能需要贴脸", function(val)
        crash_toggle = val
        BlockSyncs(pid, function()
            if val then
                local ped_pos = players.get_position(pid)
                ped_pos.z += 3
            request_model(ped_mdl)
            for i = 1, number_of_peds do
            local ped = entities.create_ped(26, ped_mdl, ped_pos, 0)
            crash_ents[i] = ped
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
            TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
            ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
            ENTITY.SET_ENTITY_VISIBLE(ped, false)
            end
            repeat
            for k, ped in crash_ents do
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            TASK.TASK_START_SCENARIO_IN_PLACE(ped, "PROP_HUMAN_BBQ", 0, false)
            end
            for k, v in entities.get_all_objects_as_pointers() do
            if entities.get_model_hash(v) == util.joaat("prop_fish_slice_01") then
            entities.delete_by_pointer(v)
            end
            end
            util.yield_once()
            until not (crash_toggle and players.exists(pid))
            crash_toggle = false
            for k, obj in crash_ents do
            entities.delete_by_handle(obj)
                end
                crash_ents = {}
            else
                for _, obj in crash_ents do
                    entities.delete_by_handle(obj)
                end
                crash_ents = {}
            end
        end)
    end)

    if bailOnAdminJoin then
        if players.is_marked_as_admin(pid) then
            util.toast(players.get_name(pid) .. "这他妈的傻逼是真的R*管理员,哥检测到了,先帮你跑路.")
            menu.trigger_commands("quickbail")
            return
        end
    end
end

players.on_join(player)
players.dispatch_on_join()

menu.toggle_loop(self, "快速脚本主机", {}, "更快版本的脚本主机", function()
    if players.get_script_host() ~= players.user() and get_transition_state(players.user()) ~= 0 then
        menu.trigger_command(menu.ref_by_path("Players>" .. players.get_name_with_tags(players.user()) .. ">Friendly>Give Script Host"))
    end
end)

local function bitTest(addr, offset)
    return (memory.read_int(addr) & (1 << offset)) ~= 0
end
menu.toggle_loop(self, "自动索赔载具", {}, "自动索赔被摧毁的载具.", function()
    local count = memory.read_int(memory.script_global(1585857))
    for i = 0, count do
        local canFix = (bitTest(memory.script_global(1585857 + 1 + (i * 142) + 103), 1) and bitTest(memory.script_global(1585857 + 1 + (i * 142) + 103), 2))
        if canFix then
            clearBit(memory.script_global(1585857 + 1 + (i * 142) + 103), 1)
            clearBit(memory.script_global(1585857 + 1 + (i * 142) + 103), 3)
            clearBit(memory.script_global(1585857 + 1 + (i * 142) + 103), 16)
            util.toast("你的载具被摧毁,正在为你自动索赔.")
        end
    end
    util.yield(100)
end)

local muggerWarning
muggerWarning = menu.action(self, "金钱删除", {}, "", function(click_type)
    menu.show_warning(muggerWarning, click_type, "警告: 请三思您的举措，一旦您使用，改变就无法撤消,打电话给拉玛.", function()
        menu.delete(muggerWarning)
        local muggerList = menu.list(self, "金钱清除")
        local price = 1000
        menu.click_slider(muggerList, "清除金额", { "muggerprice" }, "", 0, 2000000000, 0, 1000, function(value)
            price = value
        end)

        menu.toggle_loop(muggerList, "应用", {}, "", function()
            memory.write_int(memory.script_global(0x40001 + 0x1019), price)
        end)
        menu.trigger_command(muggerList)
    end)
end)

local unlocks = menu.list(self, "解锁", {}, "")

menu.action(unlocks, "解锁M16", { "" }, "", function()
    memory.write_int(memory.script_global(262145 + 32775), 1)
end)

local collectibles = menu.list(unlocks, "收藏品", {}, "")
menu.click_slider(collectibles, "电影道具", { "" }, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x0, i, 1, 1, 1 })
end)

menu.click_slider(collectibles, "隐藏包裹", { "" }, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x1, i, 1, 1, 1 })
end)

menu.click_slider(collectibles, "藏宝箱", { "" }, "", 0, 1, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x2, i, 1, 1, 1 })
end)

menu.click_slider(collectibles, "信号干扰器", { "" }, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x3, i, 1, 1, 1 })
end)

menu.click_slider(collectibles, "媒体音乐棒", { "" }, "", 0, 19, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x4, i, 1, 1, 1 })
end)

menu.action(collectibles, "沉船", { "" }, "", function()
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x5, 0, 1, 1, 1 })
end)

menu.click_slider(collectibles, "隐藏包裹", { "" }, "", 0, 1, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x6, i, 1, 1, 1 })
end)

menu.action(collectibles, "万圣节T恤", { "" }, "", function()
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x7, 1, 1, 1, 1 })
end)

menu.click_slider(collectibles, "给糖或捣乱", { "" }, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x8, i, 1, 1, 1 })
end)

menu.click_slider(collectibles, "拉玛有机坊产品", { "" }, "", 0, 99, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0x9, i, 1, 1, 1 })
end)

menu.click_slider(collectibles, "拉机能量高空跳伞", { "" }, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), { 0xB9BA4D30, 0, 0xA, i, 1, 1, 1 })
end)

local proofsList = menu.list(self, "伤害免疫", {}, "")
local immortalityCmd = menu.ref_by_path("Self>Immortality")
for _, data in pairs(proofs) do
    menu.toggle(proofsList, data.name, { data.name:lower() .. "proof" }, "让你刀枪不入 " .. data.name:lower() .. ".", function(toggle)
        data.on = toggle
    end)
end
util.create_tick_handler(function()
    local local_player = players.user_ped()
    if not menu.get_value(immortalityCmd) then
        ENTITY.SET_ENTITY_PROOFS(local_player, proofs.bullet.on, proofs.fire.on, proofs.explosion.on, proofs.collision.on, proofs.melee.on, proofs.steam.on, false, proofs.drown.on)
    end
end)

local language_codes_by_enum = {
    [0] = "en-us",
    [1] = "fr-fr",
    [2] = "de-de",
    [3] = "it-it",
    [4] = "es-es",
    [5] = "pt-br",
    [6] = "pl-pl",
    [7] = "ru-ru",
    [8] = "ko-kr",
    [9] = "zh-tw",
    [10] = "ja-jp",
    [11] = "es-mx",
    [12] = "zh-cn"
}

local my_lang = lang.get_current()

function encode_for_web(text)
    return string.gsub(text, "%s", "+")
end

function get_iso_version_of_lang(lang_code)
    lang_code = string.lower(lang_code)
    if lang_code ~= "zh-cn" and lang_code ~= "zh-tw" then
        return string.split(lang_code, '-')[1]
    else
        return lang_code
    end
end

local iso_my_lang = get_iso_version_of_lang(my_lang)

local do_translate = false
menu.toggle(session, "翻译聊天 [测试版]", { "nextton" }, "\n《 启动/关闭翻译 》\n该功能无法翻译自己发送的\n只能翻译其他人发送的消息\n会将消息自动发送在聊天\n并且其他人无法看见.\n", function(on)
    do_translate = on
end, false)

local only_translate_foreign = true
menu.toggle(session, "只翻译不同游戏语言", { "nextforeignonly" }, "仅翻译来自不同游戏语言的用户的消息，从而节省 API 调用。 您应该保持此状态，以防止 Google 暂时阻止您的请求.", function(on)
    only_translate_foreign = on
end, true)

local players_on_cooldown = {}

chat.on_message(function(sender, _, text, team_chat, networked, _)
    if do_translate and networked and players.user() ~= sender then
        local encoded_text = encode_for_web(text)
        local player_lang = language_codes_by_enum[players.get_language(sender)]
        local player_name = players.get_name(sender)
        if only_translate_foreign and player_lang == my_lang then
            return
        end
        -- credit to the original chat translator for the api code
        local translation
        if players_on_cooldown[sender] == nil then
            async_http.init("translate.googleapis.com", "/translate_a/single?client=gtx&sl=auto&tl=" .. iso_my_lang .. "&dt=t&q=" .. encoded_text, function(data)
                translation, original, source_lang = data:match("^%[%[%[\"(.-)\",\"(.-)\",.-,.-,.-]],.-,\"(.-)\"")
                if source_lang == nil then
                    util.toast("无法翻译 来自 " .. player_name)
                    return
                end
                players_on_cooldown[sender] = true
                if get_iso_version_of_lang(source_lang) ~= iso_my_lang then
                    chat.send_message(string.gsub(player_name .. ': \"' .. translation .. '\"', "%+", " "), team_chat, true, false)
                end
                util.yield(1000)
                players_on_cooldown[sender] = nil
            end, function()
                util.toast("无法翻译 来自 " .. player_name)
            end)
            async_http.dispatch()
        else
            util.toast(player_name .. "发送了一条信息,在翻译的冷却时间内. 如果该玩家在聊天中乱发垃圾信息，请考虑踢掉他，以防止被谷歌翻译暂时停止.")
        end
    end
end)

menu.toggle_loop(vehicle, "隐形无敌载具", {}, "大多数菜单不会将其检测为车辆无敌模式", function()
    ENTITY.SET_ENTITY_PROOFS(entities.get_user_vehicle_as_handle(), true, true, true, true, true, 0, 0, true)
end, function()
    ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(players.user(), false), false, false, false, false, false, 0, 0, false)
end)

menu.toggle_loop(vehicle, "转向灯", {}, "", function()
    if (PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false)) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)

        local left = PAD.IS_CONTROL_PRESSED(34, 34)
        local right = PAD.IS_CONTROL_PRESSED(35, 35)
        local rear = PAD.IS_CONTROL_PRESSED(130, 130)

        if left and not right and not rear then
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, true)
        elseif right and not left and not rear then
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, true)
        elseif rear and not left and not right then
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, true)
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, true)
        else
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, false)
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, false)
        end
    end
end)

menu.click_slider_float(vehicle, "悬挂高度", { "suspensionheight" }, "", -100, 100, 0, 1, function(value)
    value /=100
    local ped = players.user_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then return
    end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x00D0, value)
    pos.z + = 2.8
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(VehicleHandle, pos, false, false, false)
    -- Dropping vehicle so the suspension updates
end)

menu.click_slider_float(vehicle, "扭矩倍数", { "torque" }, "", 0, 1000, 100, 10, function(value)
    value /=100
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then
    return
    end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x004C, value)
end)

menu.click_slider_float(vehicle, "升档乘数", { "upshift" }, "", 0, 500, 100, 10, function(value)
    value /=100
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then
    return
    end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x0058, value)
end)

menu.click_slider_float(vehicle, "降档乘数", { "downshift" }, "", 0, 500, 100, 10, function(value)
    value /=100
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then
    return
    end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x005C, value)
end)

menu.click_slider_float(vehicle, "曲线比率乘数", { "curve" }, "", 0, 500, 100, 10, function(value)
    value /=100
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then
    return
    end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x0094, value)
end)

menu.toggle_loop(vehicle, "随机升级", {}, "仅适用于您出于某种原因生成的车辆", function()
    local mod_types = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 14, 15, 16, 23, 24, 25, 27, 28, 30, 33, 35, 38, 48 }
    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped()) then
        for _, upgrades in ipairs(mod_types) do
            VEHICLE.SET_VEHICLE_MOD(entities.get_user_vehicle_as_handle(), upgrades, math.random(0, 20), false)
        end
    end
    util.yield(100)
end)

menu.click_slider(visuals, "醉酒模式", {}, "", 0, 5, 1, 1, function(val)
    if val > 0 then
        CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", val)
        GRAPHICS.SET_TIMECYCLE_MODIFIER("Drunk")
    else
        GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
        CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 0)
    end
end)

local visions = menu.list(visuals, "屏幕效果", {}, "")
for _, data in pairs(effect_stuff) do
    local effect_name = data[1]
    local effect_thing = data[2]
    menu.toggle(visions, effect_name, { "" }, "", function(toggled)
        if toggled then
            GRAPHICS.ANIMPOSTFX_PLAY(effect_thing, 5, true)
        else
            GRAPHICS.ANIMPOSTFX_STOP_ALL()
        end
    end)
end

local visual_fidelity = menu.list(visuals, "视觉增强", {}, "")
for _, data in pairs(visual_stuff) do
    local effect_name = data[1]
    local effect_thing = data[2]
    menu.toggle(visual_fidelity, effect_name, { "" }, "", function(toggled)
        if toggled then
            GRAPHICS.SET_TIMECYCLE_MODIFIER(effect_thing)
            menu.trigger_commands("shader off")
        else
            GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
        end
    end)
end

local drug_mode = menu.list(visuals, "药物过滤器", {}, "")
for _, data in pairs(drugged_effects) do
    menu.toggle(drug_mode, data, {}, "", function(toggled)
        if toggled then
            GRAPHICS.SET_TIMECYCLE_MODIFIER(data)
            menu.trigger_commands("shader off")
        else
            GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
        end
    end)
end

menu.toggle(funfeatures, "性行为", {}, "宣布性行为的发生", function(toggled)
    local player_name

    local hooker_models = {
        "S_F_Y_Hooker_01",
        "S_F_Y_Hooker_02",
        "S_F_Y_Hooker_03"
    }
    while toggled do
        for _, pid in ipairs(players.list(true, true, true)) do
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local player_veh = PED.GET_VEHICLE_PED_IS_IN(ped)
            for _, hooker in ipairs(hooker_models) do
                local hooker_ped = util.joaat(hooker)
                if ENTITY.GET_ENTITY_MODEL(VEHICLE.GET_PED_IN_VEHICLE_SEAT(player_veh, 0)) == hooker_ped then
                    player_name = players.get_name(pid)
                    if player_name != old_player_name then
                util.yield()
                chat.send_message(player_name .. " 即将与一个妓女发生性关系", false, true, true)
                    old_player_name = player_name
                    end

                end
            end
        end
        util.yield(100)
    end
end)

if menu.get_edition() == 3 then
    local criminalDamageCmdRef = menu.ref_by_path("Online>Session>Session Scripts>Run Script>Freemode Activities>Criminal Damage")
    menu.action(funfeatures, "刑事毁坏", {}, "", function()
        if SCRIPT._GET_NUMBER_OF_REFERENCES_OF_SCRIPT_WITH_NAME_HASH(util.joaat("am_criminal_damage")) == 0 then
            menu.trigger_command(criminalDamageCmdRef)
            repeat
                util.yield()
            until SCRIPT._GET_NUMBER_OF_REFERENCES_OF_SCRIPT_WITH_NAME_HASH(util.joaat("am_criminal_damage")) ~= 0
        end
        util.yield(1000)
        repeat
            util.request_script_host("am_criminal_damage")
            util.yield()
        until NETWORK.NETWORK_GET_HOST_OF_SCRIPT("am_criminal_damage", -1, 0) == players.user()
        memory.write_int(memory.script_local("am_criminal_damage", 108 + 43), memory.read_int(memory.script_global(0x40001 + 11675)))
        util.yield(1000)
        memory.write_int(memory.script_local("am_criminal_damage", 0x67), int_max)
        util.yield(1000)
        memory.write_int(memory.script_local("am_criminal_damage", 108 + 39), memory.read_int(memory.script_global(0x40001 + 11674)))
    end)
end

menu.action(funfeatures, "自定义假R*警告", { "banner" }, "卡界面了就在菜单里关闭脚本重开就行了", function(_)
    menu.show_command_box("banner ")
end, function(text)
    custom_alert(text)
end)

local jesus_main = menu.list(funfeatures, "自动驾驶(需设置导航点)", {}, "")
local style = 786603
menu.slider_text(jesus_main, "驾驶风格", {}, "单击以选择样式", style_names, function(_, value)
    pluto_switch
    value
    do
        case
        1:
        style = 786603
        break
        case
        2:
        style = 1074528293
        break
        case
        3:
        style = 8388614
        break
        case
        4:
        style = 1076
        break
        case
        5:
        style = 2883621
        break
        case
        6:
        style = 786603
        break
        case
        7:
        style = 6
        break
        case
        8:
        style = 5
        break
    end
end)
jesus_toggle = menu.toggle(jesus_main, "启用", {}, "", function(toggled)
    if toggled then
        local ped = players.user_ped()
        local my_pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local player_veh = entities.get_user_vehicle_as_handle()

        if not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            util.toast("那你倒是先上车阿呆逼. :)")
            return
        end

        local jesus = util.joaat("u_m_m_jesus_01")
        request_model(jesus)

        jesus_ped = entities.create_ped(26, jesus, my_pos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jesus_ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(jesus_ped, true)
        PED.SET_PED_INTO_VEHICLE(ped, player_veh, -2)
        PED.SET_PED_INTO_VEHICLE(jesus_ped, player_veh, -1)
        PED.SET_PED_KEEP_TASK(jesus_ped, true)

        if HUD.IS_WAYPOINT_ACTIVE() then
            local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(jesus_ped, player_veh, pos, 9999.0, style, 0.0)
        else
            util.toast("请先设置一个导航点. :/")
            menu.set_value(jesus_toggle, false)
        end
    else
        if jesus_ped ~= nil then
            entities.delete_by_handle(jesus_ped)
        end
    end
end)

menu.toggle(funfeatures, "特斯拉自动驾驶", {}, "嘎嘎出事故\n整死你!!!!", function(toggled)
    local ped = players.user_ped()
    local playerpos = ENTITY.GET_ENTITY_COORDS(ped, false)
    local tesla_ai = util.joaat("u_m_y_baygor")
    local tesla = util.joaat("raiden")
    request_model(tesla_ai)
    request_model(tesla)
    if toggled then
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            menu.trigger_commands("deletevehicle")
        end

        tesla_ai_ped = entities.create_ped(26, tesla_ai, playerpos, 0)
        tesla_vehicle = entities.create_vehicle(tesla, playerpos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(tesla_ai_ped, true)
        ENTITY.SET_ENTITY_VISIBLE(tesla_ai_ped, false)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(tesla_ai_ped, true)
        PED.SET_PED_INTO_VEHICLE(ped, tesla_vehicle, -2)
        PED.SET_PED_INTO_VEHICLE(tesla_ai_ped, tesla_vehicle, -1)
        PED.SET_PED_KEEP_TASK(tesla_ai_ped, true)
        VEHICLE.SET_VEHICLE_COLOURS(tesla_vehicle, 111, 111)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 23, 8, false)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 15, 1, false)
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(tesla_vehicle, 111, 147)
        menu.trigger_commands("performance")

        if HUD.IS_WAYPOINT_ACTIVE() then
            local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(tesla_ai_ped, tesla_vehicle, pos, 20.0, 786603, 0)
        else
            TASK.TASK_VEHICLE_DRIVE_WANDER(tesla_ai_ped, tesla_vehicle, 20.0, 786603)
        end
    else
        if tesla_ai_ped ~= nil then
            entities.delete_by_handle(tesla_ai_ped)
        end
        if tesla_vehicle ~= nil then
            entities.delete_by_handle(tesla_vehicle)
        end
    end
end)

menu.toggle_loop(funfeatures, "洛杉矶交通", {}, "", function()
    for _, ped in ipairs(entities.get_all_peds_as_handles()) do
        TASK.SET_DRIVE_TASK_DRIVING_STYLE(ped, math.random(1, #drivingStyles))
        PED.SET_PED_KEEP_TASK(ped, true)
    end
    util.yield(1000)
end)

for _, data in pairs(interiors) do
    local location_name = data[1]
    local location_coords = data[2]
    menu.action(teleport, location_name, {}, "", function()
        menu.trigger_commands("doors on")
        menu.trigger_commands("nodeathbarriers on")
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), location_coords.x, location_coords.y, location_coords.z, false, false, false)
    end)
end

local rapid_khanjali
rapid_khanjali = menu.toggle_loop(vehicle, "TM-02可汉贾利武器快速射击", {}, "", function()
    local player_veh = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
    if ENTITY.GET_ENTITY_MODEL(player_veh) == util.joaat("khanjali") then
        VEHICLE.SET_VEHICLE_MOD(player_veh, 10, math.random(-1, 0), false)
    else
        util.toast("请先驾驶TM-02 可汗贾利.")
        menu.trigger_command(rapid_khanjali, "off")
    end
end)

local finger_thing = menu.list(funfeatures, "手指枪 [B键]", {}, "")
for _, data in pairs(weapon_stuff) do
    local name = data[1]
    local weapon_name = data[2]
    local projectile = util.joaat(weapon_name)
    while not WEAPON.HAS_WEAPON_ASSET_LOADED(projectile) do
        WEAPON.REQUEST_WEAPON_ASSET(projectile, 31, false)
        util.yield(10)
    end
    menu.toggle(finger_thing, name, {}, "", function(state)
        toggled = state
        while toggled do
            if memory.read_int(memory.script_global(4521801 + 930)) == 3 then
                memory.write_int(memory.script_global(4521801 + 935), NETWORK.GET_NETWORK_TIME())
                local inst = v3.new()
                v3.set(inst, CAM.GET_FINAL_RENDERED_CAM_ROT(2))
                local tmp = v3.toDir(inst)
                v3.set(inst, v3.get(tmp))
                v3.mul(inst, 1000)
                v3.set(tmp, CAM.GET_FINAL_RENDERED_CAM_COORD())
                v3.add(inst, tmp)
                local x, y, z = v3.get(inst)
                local fingerPos = PED.GET_PED_BONE_COORDS(players.user_ped(), 0xff9, 0, 0, 0)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(fingerPos, x, y, z, 1, true, projectile, 0, true, false, 500.0, players.user_ped(), 0)
            end
            util.yield(100)
        end
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(pos, 999999, 0)
    end)
end
local weapon_thing = menu.list(funfeatures, "子弹类型", {}, "")
for _, data in pairs(weapon_stuff) do
    local name = data[1]
    local weapon_name = data[2]
    local a = false
    menu.toggle(weapon_thing, name, {}, "", function(toggle)
        a = toggle
        while a do
            local weapon = util.joaat(weapon_name)
            projectile = weapon
            while not WEAPON.HAS_WEAPON_ASSET_LOADED(projectile) do
                WEAPON.REQUEST_WEAPON_ASSET(projectile, 31, false)
                util.yield(10)
            end
            local inst = v3.new()
            if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
                if not WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(PLAYER.PLAYER_PED_ID(), memory.addrof(inst)) then
                    v3.set(inst, CAM.GET_FINAL_RENDERED_CAM_ROT(2))
                    local tmp = v3.toDir(inst)
                    v3.set(inst, v3.get(tmp))
                    v3.mul(inst, 1000)
                    v3.set(tmp, CAM.GET_FINAL_RENDERED_CAM_COORD())
                    v3.add(inst, tmp)
                end
                local x, y, z = v3.get(inst)
                local wpEnt = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PLAYER.PLAYER_PED_ID(), false)
                local wpCoords = ENTITY._GET_ENTITY_BONE_POSITION_2(wpEnt, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(wpEnt, "gun_muzzle"))
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(wpCoords.x, wpCoords.y, wpCoords.z, x, y, z, 1, true, weapon, PLAYER.PLAYER_PED_ID(), true, false, 1000.0)
            end
            util.yield()
        end
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(pos, 999999, 0)
    end)
end

local jinx_pet
jinx_toggle = menu.toggle_loop(funfeatures, "宠物猫Jinx", {}, "招一只可爱的小猫咪\n跟着你喵喵叫\n好可爱我好喜欢！", function()
    if not jinx_pet or not ENTITY.DOES_ENTITY_EXIST(jinx_pet) then
        local jinx = util.joaat("a_c_cat_01")
        request_model(jinx)
        local pos = players.get_position(players.user())
        jinx_pet = entities.create_ped(28, jinx, pos, 0)
        PED.SET_PED_COMPONENT_VARIATION(jinx_pet, 0, 0, 1, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jinx_pet, true)
    end
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(jinx_pet)
    TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(jinx_pet, players.user_ped(), 0, -0.3, 0, 7.0, -1, 1.5, true)
    util.yield(2500)
end, function()
    entities.delete_by_handle(jinx_pet)
    jinx_pet = nil
end)

local jinx_army = {}
local army = menu.list(funfeatures, "宠物猫Jinx军队", {}, "哈哈哈，招一堆傻猫\n叫的你头疼，甩都甩不掉")
menu.click_slider(army, "生成数量", {}, "选吧，多生成点，最多256只", 1, 256, 30, 1, function(val)
    local ped = players.user_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
    pos.y = pos.y - 5
    pos.z = pos.z + 1
    local jinx = util.joaat("a_c_cat_01")
    request_model(jinx)
    for i = 1, val do
        jinx_army[i] = entities.create_ped(28, jinx, pos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jinx_army[i], true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(jinx_army[i], true)
        PED.SET_PED_COMPONENT_VARIATION(jinx_army[i], 0, 0, 1, 0)
        TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(jinx_army[i], ped, 0, -0.3, 0, 7.0, -1, 10, true)
        util.yield()
    end
end)

menu.action(army, "清除宠物猫Jinx", {}, "把这烦人的傻猫都给他们清了", function()
    for _, ped in ipairs(entities.get_all_peds_as_handles()) do
        if PED.IS_PED_MODEL(ped, util.joaat("a_c_cat_01")) then
            entities.delete_by_handle(ped)
        end
    end
end)

menu.action(funfeatures, "找到Jinx", {}, "\n将Jinx猫传送到你身边\n老叫傻猫来干嘛?\n", function()
    local ped = players.user_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
    if jinx_pet ~= nil then
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(jinx_pet, pos, false, false, false)
    else
        util.toast("找不到你那只傻猫了. :/")
    end
end)

menu.toggle_loop(detections, "无敌模式", {}, "检测是否在使用无敌.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for _, interior in ipairs(interior_stuff) do
            if (players.is_godmode(pid) or not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(ped)) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and get_transition_state(pid) ~= 0 and get_interior_player_is_in(pid) == interior then
                util.draw_debug_text(players.get_name(pid) .. "是无敌,很有可能是作弊者")
                break
            end
        end
    end
end)

menu.toggle_loop(detections, "载具无敌模式", {}, "检测载具是否在使用无敌.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local player_veh = PED.GET_VEHICLE_PED_IS_USING(ped)
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            for _, interior in ipairs(interior_stuff) do
                if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(player_veh) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and get_transition_state(pid) ~= 0 and get_interior_player_is_in(pid) == interior then
                    util.draw_debug_text(players.get_name(pid) .. "载具处于无敌模式")
                    break
                end
            end
        end
    end
end)

menu.toggle_loop(detections, "未发布车辆", {}, "检测是否有人在驾使尚未发布的车辆.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local modelHash = players.get_vehicle_model(pid)
        for _, name in ipairs(unreleased_vehicles) do
            if modelHash == util.joaat(name) then
                util.draw_debug_text(players.get_name(pid) .. "正在驾驶未发布的车辆")
            end
        end
    end
end)

menu.toggle_loop(detections, "改装武器", {}, "检测是否有人使用无法在线获得的武器.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for _, hash in ipairs(modded_weapons) do
            local weapon_hash = util.joaat(hash)
            if WEAPON.HAS_PED_GOT_WEAPON(ped, weapon_hash, false) and WEAPON.IS_PED_ARMED(ped, 7) then
                util.draw_debug_text(players.get_name(pid) .. "正在使用改装武器")
                break
            end
        end
    end
end)

menu.toggle_loop(detections, "改装载具", {}, "检测是否有人正在使用无法在线获得的车辆.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local modelHash = players.get_vehicle_model(pid)
        for _, name in ipairs(modded_vehicles) do
            if modelHash == util.joaat(name) then
                util.draw_debug_text(players.get_name(pid) .. " 正在驾驶改装载具")
                break
            end
        end
    end
end)

menu.toggle_loop(detections, "自由镜头检测", {}, "检测是否有人开启自由镜头（又称无碰撞）", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local ped_ptr = entities.handle_to_pointer(ped)
        local oldpos = players.get_position(pid)
        util.yield()
        local currentpos = players.get_position(pid)
        local vel = ENTITY.GET_ENTITY_VELOCITY(ped)
        if not util.is_session_transition_active() and players.exists(pid)
                and get_interior_player_is_in(pid) == 0 and get_transition_state(pid) ~= 0
                and not PED.IS_PED_IN_ANY_VEHICLE(ped, false) -- too many false positives occured when players where driving. so fuck them. lol.
                and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped)
                and not PED.IS_PED_CLIMBING(ped) and not PED.IS_PED_VAULTING(ped) and not PED.IS_PED_USING_SCENARIO(ped)
                and not TASK.GET_IS_TASK_ACTIVE(ped, 160) and not TASK.GET_IS_TASK_ACTIVE(ped, 2)
                and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) <= 395.0 -- 400 was causing false positives
                and ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(ped) > 5.0 and not ENTITY.IS_ENTITY_IN_AIR(ped) and entities.player_info_get_game_state(ped_ptr) == 0
                and oldpos.x ~= currentpos.x and oldpos.y ~= currentpos.y and oldpos.z ~= currentpos.z
                and vel.x == 0.0 and vel.y == 0.0 and vel.z == 0.0 then
            util.toast(players.get_name(pid) .. " 是无碰撞")
            break
        end
    end
end)

menu.toggle_loop(detections, "超级驾驶检测", {}, "检测是否有在修改载具车速", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local veh_speed = (ENTITY.GET_ENTITY_SPEED(vehicle) * 2.236936)
        local class = VEHICLE.GET_VEHICLE_CLASS(vehicle)
        if class ~= 15 and class ~= 16 and veh_speed >= 180 and VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1) and players.get_vehicle_model(pid) ~= util.joaat("oppressor") then
            -- not checking opressor mk1 cus its stinky
            util.toast(players.get_name(pid) .. " 正在使用超级驾驶")
            break
        end
    end
end)

menu.toggle_loop(detections, "观看检测", {}, "检测是否有人在观看你.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        for _, interior in ipairs(interior_stuff) do
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            if not util.is_session_transition_active() and get_transition_state(pid) ~= 0 and get_interior_player_is_in(pid) == interior
                    and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped) then
                if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_cam_pos(pid)) < 15.0 and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 20.0 then
                    util.toast(players.get_name(pid) .. " 正在观看你")
                    break
                end
            end
        end
    end
end)

menu.toggle_loop(detections, "传送检测", {}, "检测是否有玩家进行了传送", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped) then
            local oldpos = players.get_position(pid)
            util.yield(1000)
            local currentpos = players.get_position(pid)
            for _, interior in ipairs(interior_stuff) do
                if v3.distance(oldpos, currentpos) > 500 and oldpos.x ~= currentpos.x and oldpos.y ~= currentpos.y and oldpos.z ~= currentpos.z
                        and get_transition_state(pid) ~= 0 and get_interior_player_is_in(pid) == interior and PLAYER.IS_PLAYER_PLAYING(pid) and players.exists(pid) then
                    util.toast(players.get_name(pid) .. " 刚刚进行了传送")
                end
            end
        end
    end
end)
menu.toggle_loop(protections, "拦截劫匪", {}, "", function()
    -- thx nowiry for improving my method :D
    if NETWORK.NETWORK_IS_SCRIPT_ACTIVE("am_gang_call", 0, true, 0) then
        local ped_netId = memory.script_local("am_gang_call", 63 + 10 + (0 * 7 + 1))
        local sender = memory.script_local("am_gang_call", 287)
        local target = memory.script_local("am_gang_call", 288)
        local player = players.user()

        util.spoof_script("am_gang_call", function()
            if (memory.read_int(sender) ~= player and memory.read_int(target) == player
                    and NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(memory.read_int(ped_netId))
                    and NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(memory.read_int(ped_netId))) then
                local mugger = NETWORK.NET_TO_PED(memory.read_int(ped_netId))
                entities.delete_by_handle(mugger)
                util.toast("拦截劫匪来自 " .. players.get_name(memory.read_int(sender)))
            end
        end)
    end
end)

local anticage = menu.list(protections, "防笼子", {}, "")
local alpha = 160
menu.slider(anticage, "笼子Alpha", { "cagealpha" }, "物体将具有的透明度", 0, #values, 3, 1, function(amount)
    alpha = values[amount]
end)

menu.toggle_loop(anticage, "启用拦截", { "anticage" }, "", function()
    local user = players.user_ped()
    local veh = PED.GET_VEHICLE_PED_IS_USING(user)
    local my_ents = { user, veh }
    for _, obj_ptr in ipairs(entities.get_all_objects_as_pointers()) do
        local net_obj = memory.read_long(obj_ptr + 0xd0)
        if net_obj == 0 or memory.read_byte(net_obj + 0x49) == players.user() then
            continue
        end
        local obj_handle = entities.pointer_to_handle(obj_ptr)
        CAM._DISABLE_CAM_COLLISION_FOR_ENTITY(obj_handle)
        for _, data in ipairs(my_ents) do
            if data ~= 0 and ENTITY.IS_ENTITY_TOUCHING_ENTITY(data, obj_handle) and alpha > 0 then
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(obj_handle, data, false)
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(data, obj_handle, false)
                ENTITY.SET_ENTITY_ALPHA(obj_handle, alpha, false)
            end
            if data ~= 0 and ENTITY.IS_ENTITY_TOUCHING_ENTITY(data, obj_handle) and alpha == 0 then
                entities.delete_by_handle(obj_handle)
            end
        end
        SHAPETEST.RELEASE_SCRIPT_GUID_FROM_ENTITY(obj_handle)
    end
end)

menu.list_action(protections, "全部清除...", {}, "", { "NPC", "载具", "物体", "可拾取物体", "绳索", "投掷物", "声音" }, function(index, name)
    util.toast("Clearing " .. name:lower() .. "...")
    local counter = 0
    pluto_switch
    index
    do
        case
        1:
        for _, ped in ipairs(entities.get_all_peds_as_handles()) do
            if ped ~= players.user_ped() and not PED.IS_PED_A_PLAYER(ped) and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ped) and (not NETWORK.NETWORK_IS_ACTIVITY_SESSION() or NETWORK.NETWORK_IS_ACTIVITY_SESSION() and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped)) then
                entities.delete_by_handle(ped)
                counter += 1
                util.yield()
            end
        end
        break
        case
        2:
        for _, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
            if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) and DECORATOR.DECOR_GET_INT(vehicle, "Player_Vehicle") == 0 and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
                entities.delete_by_handle(vehicle)
                counter += 1
            end
            util.yield()
        end
        break
        case
        3:
        for _, object in ipairs(entities.get_all_objects_as_handles()) do
            entities.delete_by_handle(object)
            counter += 1
            util.yield()
        end
        break
        case
        4:
        for _, pickup in ipairs(entities.get_all_pickups_as_handles()) do
            entities.delete_by_handle(pickup)
            counter += 1
            util.yield()
        end
        break
        case
        5:
        local temp = memory.alloc(4)
        for i = 0, 101 do
            memory.write_int(temp, i)
            if PHYSICS.DOES_ROPE_EXIST(temp) then
                PHYSICS.DELETE_ROPE(temp)
                counter += 1
            end
            util.yield()
        end
        break
        case
        6:
        local coords = players.get_position(players.user())
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, 1000, 0)
        counter = "所有"
        break
        case
        4:
        for i = 0, 99 do
            AUDIO.STOP_SOUND(i)
            util.yield()
        end
        break
    end
    util.toast("已清除 " .. tostring(counter) .. " " .. name:lower() .. ".")
end)

menu.action(protections, "清除区域", { "cleanse" }, "", function()
    local cleanse_entitycount = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ped ~= players.user_ped() and not PED.IS_PED_A_PLAYER(ped) and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ped) and (not NETWORK.NETWORK_IS_ACTIVITY_SESSION() or NETWORK.NETWORK_IS_ACTIVITY_SESSION() and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped)) then
            entities.delete_by_handle(ped)
            cleanse_entitycount += 1
            util.yield()
        end
    end
    util.toast("已清除 " .. cleanse_entitycount .. " Peds")
    cleanse_entitycount = 0
    for _, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
        if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) and DECORATOR.DECOR_GET_INT(vehicle, "Player_Vehicle") == 0 and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
            entities.delete_by_handle(vehicle)
            cleanse_entitycount += 1
            util.yield()
        end
    end
    util.toast("已清除 " .. cleanse_entitycount .. " 载具")
    cleanse_entitycount = 0
    for _, object in pairs(entities.get_all_objects_as_handles()) do
        entities.delete_by_handle(object)
        cleanse_entitycount += 1
        util.yield()
    end
    util.toast("已清除 " .. cleanse_entitycount .. " 物体")
    cleanse_entitycount = 0
    for _, pickup in pairs(entities.get_all_pickups_as_handles()) do
        entities.delete_by_handle(pickup)
        cleanse_entitycount += 1
        util.yield()
    end
    util.toast("已清除 " .. cleanse_entitycount .. " 可拾取物体")
    local temp = memory.alloc(4)
    for i = 0, 100 do
        memory.write_int(temp, i)
        PHYSICS.DELETE_ROPE(temp)
    end
    util.toast("已清除所有绳索")
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_PROJECTILES(pos, 400, 0)
    util.toast("已清除所有投掷物")
end)

local misc = menu.list(menu.my_root(), "其他选项", {}, "")
menu.hyperlink(misc, "加入脚本中文交流", "https://jq.qq.com/?_wv=1027&k=R51P3MOS")
menu.hyperlink(menu.my_root(), "加入官方Discord", "https://discord.gg/hjs5S93kQv")
local credits = menu.list(misc, "鸣谢", {}, "")
local jinx = menu.list(credits, "Jinx", {}, "")
menu.hyperlink(jinx, "Tiktok", "https://www.tiktok.com/@bigfootjinx")
menu.hyperlink(jinx, "Twitter", "https://twitter.com/bigfootjinx")
menu.hyperlink(jinx, "Instagram", "https://www.instagram.com/bigfootjinx")
menu.hyperlink(jinx, "Youtube", "https://www.youtube.com/channel/UC-nkxad5MRDuyz7xstc-wHQ?sub_confirmation=1")
menu.action(credits, "ICYPhoenix", {}, "如果他没有将我的名字改为OP Jinx Lua,我将永远不会制作这个脚本或想过制作这个脚本", function()
end)
menu.action(credits, "Sapphire", {}, "当我第一次启动 Lua 以及开始学习Stand API和natives时,他处理了我所有的困难并帮助了很多人", function()
end)
menu.action(credits, "aaronlink127", {}, "帮助处理数学问题,还帮助处理自动更新程序和其他一些功能", function()
end)
menu.action(credits, "Ren", {}, "提出合理建议", function()
end)
menu.action(credits, "well in that case", {}, "用于制作Pluto并让我的部分代码看起来更好,运行更流畅", function()
end)
menu.action(credits, "jerry123", {}, "清理我的某些代码并告诉我可以改进的地方", function()
end)
menu.action(credits, "Scriptcat", {}, "从我制作这个脚本开始就陪着我,告诉我一些有用的 Lua 技巧,并教导我开始学习Stand API和natives", function()
end)
menu.action(credits, "ERR_NET_ARRAY", {}, "帮助编辑", function()
end)
menu.action(credits, "d6b.", {}, "给我赠送Discord Nitro", function()
end)

local translation = menu.list(credits, "翻译人员", {}, "translation")
menu.action(translation, "BLackMist / 臣服", {}, "中文区翻译,目前Jinx翻译者.", function()
end)
menu.action(translation, "Lu_zi / 鹿子", {}, "中文区翻译,翻译了太多版本于2022/9/4离开Jinx.", function()
end)

menu.action(menu.my_root(), "查看玩家的功能", {}, "", function()
    menu.trigger_commands("jinxscript " .. players.get_name(players.user()))
end)

util.keep_running()
