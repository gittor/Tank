
global = {

	-- 常量
	layer_offset = (display.width-display.height)/2,
	-- dir_offset = (display.width-display.height)/2+display.height+20,
	-- dir_offset = 20,

	p1_born = {x=4*60,y=0},
	p2_born = {x=8*60, y=0},

	zTank = 1000,
	zBlock = 2000,
	zProp = 3000,
	zTips = 4000,

	-- 说明

	-- 所有的速度以 0.01s 走 1 pixel 为基准(也就是坦克移动的最慢速度)

	-- bullet damage
	-- 1: 半个brick
	-- 2: 一个brick 一个iron

	-- 吃一个星星升一级

	-- 场景切换也需要保持的变量
	p1Level = 1,
	p2Level = 1,

	cur_stage = 1,

	lifes = 2,
	stars = 0,

	totalScore = 0,

	-- GameScene独有的变量
	game_scene = nil,

	p1 = nil,
	p2 = nil,

	levelScore = 0,
}