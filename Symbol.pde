class Symbol {

  int id;
  float symbolWidth;
  float symbolHeight;
  float angle;
  float angleInc;
  float minRotation = 1.5;
  float maxRotation = 3.;
  color fromColor = color(193, 60, 88);
  color toColor = color(318, 36, 82);
  color lineColor;

// --------------------------------------------------------------------------------
  Symbol( int _id) {
    id = _id;
    symbolWidth =  height / 4.6452;  // 310
    symbolHeight =  height / 2.; // 720
    // --------------------- set color depending on id number
    float percentage = map(id, 0, symbolNum-1, 0., 1.);
    if (id == 0) {
      lineColor = fromColor;
    }
    else {
      lineColor = lerpColor(fromColor, toColor, percentage);
    }
    // --------------------- set initial angle and angleInc depending on id number
    angle = map(id, 0, symbolNum-1, 0., -40);
    if (id == 0) {
      angle = 0;
    }
    angleInc = map(id, 0, symbolNum-1, minRotation, maxRotation);
    if (id == 0) {
      angleInc = minRotation;
    }
  }
// --------------------------------------------------------------------------------
  void display() {
    pushMatrix();
    rotate( radians(angle) );
    stroke( hue(lineColor), saturation(lineColor), brightness(lineColor) );
    noFill();
    strokeWeight(strokeWeight_2);
    ellipse(0, 0, symbolWidth, symbolHeight);
    popMatrix();
    angle += angleInc;
  }
}

