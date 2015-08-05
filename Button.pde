class Button
{
  float x, y;
  float buttonWidth, buttonHeight;
  boolean enabled = true;
  String theText = "";
  // variables for drawing triangle inside button
  float tx;
  float ty;
  float tRad;


  Button(float _x, float _y, float _buttonWidth, float _buttonHeight) 
  {
    x = _x;
    y = _y;
    buttonWidth = _buttonWidth;
    buttonHeight = _buttonHeight;
    tx = x + buttonWidth/2.;
    ty = y + buttonHeight/2.;
    tRad = buttonWidth * 0.35;
  }

  // ---------------------------------------- 
  void display() 
  {
    /*
     if (theText=="START NOW" || theText=="SETTINGS" || theText=="LICENSES" || theText=="FLIP CAMERA") {
     // do nothing: invisible buttons, 
     // they don't need to be excluded here, as the display function is not called when they should not be active
     } 
     else 
     */
    if (theText=="RESTART CREATING") {  // special exit/menu  button:
      // -------------------- draw cross for the continue play button
      float crossWidth = buttonHeight * 0.36;
      float gap = (buttonHeight - crossWidth)/2.;
      strokeWeight(strokeWeight_6); 
      stroke( getBlackOrOpposite() );
      line(x + gap, y + gap, x + buttonWidth - gap, y + buttonHeight - gap);
      line(x + gap, y + buttonHeight - gap, x + buttonWidth - gap, y + gap);
    } 
    else if (theText == "ACCESS MENU") {
      // -------------------- draw menu button svg
      strokeWeight(strokeWeight_2); 
      stroke( getBlackOrOpposite(), menuButtonAccessMenuCurrentTrans );
      shape( settingsButton, 0, 0, width, height );
    }  
    else if (theText == "UP") {
      // -------------------- draw border
      strokeWeight(strokeWeight_2);
      stroke( getDarkGreyOrOpposite() );
      noFill();
      rect(x, y, buttonWidth, buttonHeight);

      // draw line from "up" to "down" button
      float x1 = x + buttonWidth/2.;
      float y1 = y + buttonHeight;
      float x2 = x1;
      float y2 = height - textBorder - buttonHeight;
      line(x1, y1, x2, y2);

      // -------------------- draw "up" triangle
      noStroke();
      fill( getDarkGreyOrOpposite() );
      drawTriangle(tx, ty, tRad, "UP");
    }
    else if (theText == "DOWN") {
      // -------------------- draw border
      strokeWeight(strokeWeight_2);
      stroke( getDarkGreyOrOpposite() );
      noFill();
      rect(x, y, buttonWidth, buttonHeight);
      // -------------------- draw "down" triangle
      noStroke();
      fill( getDarkGreyOrOpposite() );
      drawTriangle(tx, ty, tRad, "DOWN");
    }
  } // end  void display() 


  // ---------------------------------------- 
  void setEnabled(boolean _enabled) {
    enabled = _enabled;
  } // end void setEnabled(boolean _enabled)


  // ---------------------------------------- 
  float getEnabledFloat() {
    if (enabled) {
      return 1.;
    }
    else {
      return 0;
    }
  } // end  float getEnabledFloat()


  // ---------------------------------------- 
  boolean overRect() 
  {
    if (mouseX >= x && mouseX <= x+buttonWidth && 
      mouseY >= y && mouseY <= y+buttonHeight) {
      return true;
    } 
    else {
      return false;
    }
  } // end boolean overRect()


  // ---------------------------------------- 
  void drawTriangle(float cx, float cy, float rad, String direction) {
    float angle;
    if (direction == "UP") {
      angle = 60;
    }
    else {
      angle = 0;
    }
    beginShape();
    // -----------  fill corner points list
    for (int i = 0; i<3; i++) {
      float tx = cx + rad * sin(angle*PI/180);
      float ty = cy + rad * cos(angle*PI/180);
      vertex(tx, ty);
      angle += 120; // fixed number, because it is a triangle
    }
    endShape(CLOSE);
  } // end void drawTriangle(float cx, float cy, float rad, String direction)
} // end class Button

