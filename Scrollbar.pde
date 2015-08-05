class Scrollbar
{
  String theText;
  float barX, barY;
  float barWidth, barHeight;

  float sliderPos, sliderNewPosX;
  float sliderPosMinX, sliderPosMaxX;
  float sliderDiameter;

  boolean over; 
  boolean locked;

  float reactionSpeed;

  Scrollbar (float _barX, float _barY, float _barWidth, float _barHeight, float _reactionSpeed, String _whichScrollbar) {
    barX = _barX;
    barY = _barY; 
    barWidth = _barWidth;
    barHeight = _barHeight;
    reactionSpeed = _reactionSpeed;

    sliderDiameter = barHeight * 0.37;
    // -------------------- set scrollbar to value between 0 and 1
    // if no parameters exist, then slider starts at a bit to the left of the center (*0.4), 
    // if it would start in the center, then
    // the value would be 0 and nothing would move/rotate
    if (parametersExist) {
      float mappedParameter;
      if (_whichScrollbar == "SPEED") {
        mappedParameter = map(param1_speedScrollbar, -1, +1, 0, 1);
        sliderPos = barX + (barWidth - sliderDiameter) * mappedParameter;
      }
      if (_whichScrollbar == "ROTATION") {
        mappedParameter = map(param2_rotationScrollbar, -1, +1, 0, 1);
        sliderPos = barX + (barWidth - sliderDiameter) * mappedParameter;
      }
    }
    else {
      sliderPos = barX + (barWidth - sliderDiameter) * 0.4;
    }
    sliderNewPosX = sliderPos;
    sliderPosMinX = barX;
    sliderPosMaxX = barX + barWidth - sliderDiameter;
  } // end constructor


    // ---------------------------------------- 
  void update() {
    if (overBar() && !someScrollbarClicked) {
      over = true;
    } 
    else {
      over = false;
    }
    if (mousePressed && over && !someScrollbarClicked) {
      locked = true;
      someScrollbarClicked = true;
    }
    if (!mousePressed) {
      locked = false;
      someScrollbarClicked = false;
    }

    if (locked && someScrollbarClicked) { 
      // -------------------- updating the value of the scrollbar:
      sliderNewPosX = constrain( (mouseX-sliderDiameter), sliderPosMinX, sliderPosMaxX );

      // -------------------- setting new vertical speed for all shapes
      if (theText=="SPEED") {
        for (int i=0; i<theShapes.size();i++) {
          theShapes.get(i).setVerticalSpeed();
        }
      } // end if (theText=="SPEED")

      // -------------------- setting new angle speed for all shapes
      if (theText=="ROTATION") {
        for (int i=0; i<theShapes.size();i++) {
          theShapes.get(i).setAngleSpeed();
        }
      } // end if (theText=="ROTATION")


      // -------------------- move slider
      if (abs(sliderNewPosX - sliderPos) > 1) {
        sliderPos = sliderPos + (sliderNewPosX-sliderPos)/reactionSpeed;
      }
    } // end if (locked && someScrollbarClicked)
  } // end void update()


  // ----------------------------------------
  void display() {
    // -------------------- line of the lenght of the scrollbar
    strokeCap(SQUARE);
    strokeWeight(strokeWeight_8);
    stroke( getLightGreyOrOpposite());
    line(barX, barY + barHeight/2., barX + barWidth, barY + barHeight/2.);
     // ------------------- small vertical line in the center of the scrollbar
     strokeWeight(strokeWeight_2);
    line(barX + barWidth/2., barY + barHeight * 0.27 , barX + barWidth/2., barY + barHeight * 0.73);
    // -------------------- line from left of scrollbar to slider position
    stroke( getBlackOrOpposite());
    line(barX, barY + barHeight/2., sliderPos, barY + barHeight/2.);
    strokeCap(ROUND);  // end of slider lines: change strokeCap back
    // -------------------- slider circle
    ellipseMode(CENTER);
    fill( getBlackOrOpposite() );
    noStroke();
    ellipse(sliderPos+sliderDiameter/2., barY + barHeight/2., sliderDiameter, sliderDiameter);
  } // end void display()


  // ----------------------------------------
  boolean overBar() {
    // adding 1 * barheight at Y axis on top and bottom to make handle more easy to grab
    if (mouseX > barX && mouseX < (barX + barWidth) && mouseY > barY - barHeight && mouseY < (barY + 2 * barHeight) ) {
      return true;
    } 
    else {
      return false;
    }
  } // end boolean overBar()


  // ----------------------------------------
  float getPos() {
    // return values between -1 and +1
    float posValues = map(sliderPos, sliderPosMinX, sliderPosMaxX, -1, 1);
    return posValues;
  } // end float getPos()
} // end class Scrollbar

