function func_BIRD_TOUCH()
{
   gotoAndStop("frm_BIRD_FLY");
   play();
}
stop();
v_FluffChance = 17;
v_FlyAwayChance = 51;
v_FlyBackChance = 55;
BIRD.onRollOver = function()
{
   func_BIRD_TOUCH();
};
