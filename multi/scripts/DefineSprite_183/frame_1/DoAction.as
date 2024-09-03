function func_ACTION_1(p_Choice)
{
   if(p_Choice < 15)
   {
      play();
   }
   else
   {
      gotoAndStop("frm_FLUFF");
      play();
   }
}
function func_ACTION_2(p_Choice)
{
   if(p_Choice < 50)
   {
      gotoAndStop(1);
   }
   else
   {
      this._parent.gotoAndPlay("frm_BIRD_FLY");
   }
}
function func_RANDOMIZE(p_MaxNum, p_FuncNum)
{
   v_BirdChoice = random(p_MaxNum);
   v_FunctionCall = "func_ACTION_" + p_FuncNum;
   v_FunctionCall(v_BirdChoice);
}
stop();
func_RANDOMIZE(this._parent.v_FluffChance,1);
