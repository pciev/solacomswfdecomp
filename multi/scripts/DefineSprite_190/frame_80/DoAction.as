function func_FLY_IN()
{
   v_BirdChoice = random(v_FlyBackChance);
   if(v_BirdChoice > 50)
   {
      clearInterval(v_BirdThinking);
      gotoAndStop("frm_BIRD_FLY_IN");
      play();
   }
}
stop();
v_BirdThinking = setInterval(func_FLY_IN,5000);
