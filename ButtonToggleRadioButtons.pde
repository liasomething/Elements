class ButtonToggleRadioButtons {

  float x, y;
  float buttonWidth, buttonHeight;
  RadioButton topRadioButton;
  RadioButton bottomRadioButton;

  ButtonToggleRadioButtons(float _x, float _y, float _buttonWidth, float _buttonHeight) {
    x = _x;
    y = _y;
    buttonWidth = _buttonWidth;
    buttonHeight = _buttonHeight;
    float radioButtonDiameter = height / 27.6923; // 52
    float radioButtonOffset = (height / 28.8); // 50
    float radioButtonX = x + radioButtonOffset; // 50
    float topRadioButtonY = y + (radioButtonOffset/2.) ; // 25 
    float bottomRadioButtonY = y + buttonHeight - radioButtonDiameter - (radioButtonOffset/2.); // 25
    topRadioButton = new RadioButton(radioButtonX, topRadioButtonY, radioButtonDiameter);
    bottomRadioButton = new RadioButton(radioButtonX, bottomRadioButtonY, radioButtonDiameter);
  }

  // ---------------------------------------- 
  void display() {
    topRadioButton.display();
    bottomRadioButton.display();
  } // end void display()

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
  } // end  boolean overRect()
} // end class ButtonToggleRadioButtons

