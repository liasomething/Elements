class RadioButton {
  float x, y;
  float diameter;
  boolean enabled;

  RadioButton(float _x, float _y, float _diameter) {
    x = _x;
    y = _y;
    diameter = _diameter;
  }

  // ---------------------------------------- 
  void display() {
    ellipseMode(CORNER);
    // -------------------- draw empty cirle
    strokeWeight(strokeWeight_4);
    if (enabled) {
      stroke( getDarkGreyOrOpposite() );
    }
    else {
      stroke( getLightGreyOrOpposite()  );
    }
    noFill();
    ellipse(x, y, diameter, diameter);
    // -------------------- draw "checked" circle inside empty circle
    if (enabled) {
      fill( getDarkGreyOrOpposite() );
      noStroke();
      ellipse(x + diameter * 0.2, y + diameter * 0.2, diameter * 0.6, diameter * 0.6);
    }
  } // end void display()

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
  } //  end  float getEnabledFloat()
} // end class RadioButton

