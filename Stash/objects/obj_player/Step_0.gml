
depth = -bbox_bottom

var _spd = 2
x += (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * _spd
y += (keyboard_check(ord("S")) - keyboard_check(ord("W"))) * _spd

if (x != xprevious) {
	image_xscale = sign(x - xprevious != 0 ? x - xprevious : image_xscale)
}

var _list = ds_list_create()
var _num = collision_circle_list(x, y, 16, obj_coin, false, true, _list, true)
for (var i = 0; i < _num; i++) {
	var _coin = _list[| i]
	instance_destroy(_coin)
	global.data.player.coins++
}