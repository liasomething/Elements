// -------------------- variables for displaying licensing text
String[] licenses;
int numberOfLicensesLines = 13;
String[] justFewLinesOfLicensesText = new String[numberOfLicensesLines * 2];
int licensesStartIndex;
float textBorder;

// -------------------- variables for svg files
PShape startScreenAndroidExperiment;
PShape startScreenButtons_Boxes;
PShape startScreenButtons_Text;
PShape settingsButton;
PShape menuScreenButtons_Titles;
PShape menuScreenButtons_ButtonsText;
PShape menuScreenButtons_ButtonsText_onlyOneCam;
PShape menuScreenButtons_Lines;

// -------------------- variables for the start screen symbol
int symbolNum = 10;
Symbol[] symbols = new Symbol[symbolNum];

// -------------------- variables for colors
color currentAverageCamColor;
int hueRange = 360; 
int[] hues = new int[hueRange];
float[] saturations = new float[hueRange];
float[] brightnesses = new float[hueRange];
// colors start with black, then they change into cam colors
float currentHue = 0;
float currentSaturation = 0;
float currentBrightness = 0;
float targetHue = currentHue;
float targetSaturation = currentSaturation;
float targetBrightness = currentBrightness;

// -------------------- variables for saving/reading parameters to/from external file 
boolean parametersExist; // set true or false when trying to read file
String parametersFile = "parameters.txt";
PrintWriter output;
BufferedReader reader;
// initial values are set in case parameters textfile does not exist
float param1_speedScrollbar;
float param2_rotationScrollbar;
float param3_frontCam;
float param4_shapeRounded;
float param5_shapeFilled;
float param6_shapeClosed;
float param7_whiteBackground;
float param8_backCamFlipped;
float param9_frontCamFlipped;

// -------------------- font
PFont myFont;
PFont myFontBold;

// -------------------- ketai gestures for doubleClick
import android.view.MotionEvent;
import ketai.ui.*;
KetaiGesture gesture;

// -------------------- ketai camera
import ketai.camera.*;
KetaiCamera cam;
boolean camShouldStart = true;
int camSwitchAfterFrames = -1; // so that the button changes first, THEN the camera changes, as this takes some time
// -------------------- default variables for "cam flipped" parameters and for the case only one camera exists
boolean frontCamFlipped = true;
boolean backCamFlipped = false;
boolean onlyOneCam = false;

// -------------------- default variables for shape parameters
boolean shapeFilled = false;
boolean shapeRounded = true;
boolean shapeClosed = false;
boolean whiteBackground = false;

// -------------------- lists for storing corner points and for storing created shapes
ArrayList<PVector> thePoints = new ArrayList<PVector>(); // list for stroing clicked points
ArrayList<TheShape> theShapes = new ArrayList<TheShape>(); // list for storing created shapes

// -------------------- lists for immediately showing a spline when drawing
ArrayList<PVector> drawingControlPoints = new ArrayList<PVector>();
ArrayList<PVector> drawingAnchorPoints = new ArrayList<PVector>();
boolean drawing = false; // true when user draws new shapes
float pmx, pmy; // previously drawn mouse points

// -------------------- lists for drawing the preview shape either pointy or rounded
PVector[] cornerPointsPreviewShape = new PVector[3]; // always a triangle
PVector[] anchPreviewShape = new PVector[3+1]; // + 1 for closed shapes, preview shape is always closed, just displayed differently
PVector[] ctrPreviewShape = new PVector[6];

// ---------------------------------------- 
// interface variables
// ---------------------------------------- 

// -------------------- colors (defined in RGB BEFORE colorMode is set to HSB !)
color black = color(0);
color white = color(255);

color darkGrey = color(80);
color darkGreyOnBlackBg = color(255-80);

color lightGrey = color(150);
color lightGreyOnBlackBg = color(255-150);

color veryDarkGrey = color(50);
color veryDarkGreyOnBlackBg = color(255-50);

// -------------------- text sizes
float textSize_40;
float textSize_60; // buttons and slider text
float textSize_100; // titles in the menu
float textSize_200; // start screen "Elements"
float textSpacing_170; // for spacing the start screen text "ELEMENTS"

// -------------------- stroke widths
float strokeWeight_2;
float strokeWeight_4;
float strokeWeight_6;
float strokeWeight_8;
float strokeWeight_10;

// -------------------- dotted line that splits the screen
float dottedLineEllipseDiameter;

// -------------------- menu items
float menuItemsLeftX; // left column x position
float menuItemsMiddleX; // right column x position

// -------------------- dimensions of buttons with radio buttons
float menuToggleButtonW; 
float menuToggleButtonH;

// -------------------- variables for buttons with radio buttons in the right column
float menuButtonsLeftColumnX;
float menuButtonsRightColumnX;
float menuButtonsTopRowY;
float menuButtonsBottomRowY;

// ------------------------ start screen buttons
float startScreenButtonW;
float startScreenButtonH;

Button startScreenButtonStartNow;
Button startScreenButtonSettings;

// ------------------------ create screen / liceses screen button: access menu cross
float menuButtonAccessMenuCurrentTrans = 255;
float menuButtonAccessMenuTargetTrans = 0; 
Button menuButtonAccessMenu;

// ------------------------ menu screen buttons
ButtonToggleRadioButtons menuToggleButtonShapeRoundedOrPointy; // shapeRounded / shapePointy
ButtonToggleRadioButtons menuToggleButtonShapeFilledOrOutlined; // shapeFilled / shapeOutlined
ButtonToggleRadioButtons menuToggleButtonShapeClosedOrOpen; // shapeClosed / shapeOpen
ButtonToggleRadioButtons menuToggleButtonBgWhiteOrBlack; // white bg / black bg
ButtonToggleRadioButtons menuToggleButtonHCam; // cam front / back

float camX, camY, camWidth, camHeight; // declared here, because front cam needs vertical flipping
Button menuButtonFlipCam;

Button menuButtonContinuePlay; // cross button: continue play / exit licensing screen

float licensesButtonW;
float licensesButtonH;
Button menuButtonLicenses;

// ------------------------ licenses screen buttons
Button licensesButtonUp;
Button licensesButtonDown;

// ------------------------ srollbars
Scrollbar speedScrollbar;
Scrollbar rotationScrollbar;
boolean someScrollbarClicked = false; // to prevent that more than one scrollbar can be moved with one finger
float scrollbarWidth;
float scrollbarHeight;
float speedScrollbarY;
float rotationScrollbarY;

// ------------------------ timer
// to avoid that the second click of doubleTap already becomes the first click in EMPTY_CREATE_SCREEN mode
float startTime;
float elapsedTime;

// ------------------------ mode
Mode mode = Mode.START_SCREEN; 

// ------------------------ limit number of corner points per shape and number of shapes
int maxNumberOfCornerPointsPerShape = 20;
int maxNumberOfAllCornerPoints = 50; // has to be more than maxNumberOfCornerPointsPerShape, otherwise i can just draw ONE long shape!
int countNumberOfAllCornerPoints = 0;
int maxNumberOfShapes = 4; // one less visible
float distForDrawingNewPoints; // min distance to avoid too many points next to each other

// -------------------- for mirroring the shapes: add/substract from mouseX later !
float translateX; 

// --------------------------------------------------------------------------------
@Override
public void onPause() {
  super.onPause();
  // release cam as other activities might need to use it
  if (cam != null) {
    cam.stop();
  }
}

// --------------------------------------------------------------------------------
@Override
public void onResume() {
  super.onResume();
  if (cam != null) {
    cam.start();
  }
}

// --------------------------------------------------------------------------------
void setup() {
  size(displayWidth, displayHeight);
  //  orientation(LANDSCAPE); // this is now set in the manifest file
  frameRate(30);
  colorMode(HSB, 360, 100, 100); // defined after setting inital colors

  // ------------------------ fill list with symbol objects
  for (int i=0; i<symbolNum; i++) {
    symbols[i] = new Symbol(i);
  }

  // ------------------------ for mirroring the shapes along the y axis, set BEFORE CAM !!!
  translateX = width/2.; 

  // ------------------------ ketai gestures: only doubleTap is needed
  gesture = new KetaiGesture(this);

  // ------------------------ set up ketai camera
  cam = new KetaiCamera(this, 200, 150, 24);

  if ( cam.getNumberOfCameras() > 1  ) {
    onlyOneCam = false;
  }
  else {
    onlyOneCam = true;
  }

  // ------------------------ licenses text
  licenses =  loadStrings("licenses.txt");
  licensesStartIndex = 0;
  readLicensesTextAndChooseLines();

  // ------------------------ import parameters and set values if the parameters file exists
  importParameters(); // AFTER cam!
  setParametersValues();

  // ------------------------ uses the device height to set all sorts of values
  setValuesRelativeToDeviceHeightOrWidth();

  // ------------------------ create font
  myFont = createFont("RobotoMono-Thin.ttf", textSize_200, true);
  myFontBold = createFont("RobotoMono-Medium.ttf", textSize_40, true);

  textFont(myFont);
  // ------------------------ import svg files and disable their style, so that the color can change according to the bg color
  startScreenAndroidExperiment = loadShape("startScreenAndroidExperiment.svg");
  startScreenAndroidExperiment.disableStyle();

  startScreenButtons_Boxes = loadShape("startScreenButtons_Boxes.svg");
  startScreenButtons_Boxes.disableStyle();

  startScreenButtons_Text = loadShape("startScreenButtons_Text.svg");
  startScreenButtons_Text.disableStyle();

  settingsButton = loadShape("settingsButton.svg");
  settingsButton.disableStyle();

  menuScreenButtons_Titles = loadShape("menuScreenButtons_Titles.svg");
  menuScreenButtons_Titles.disableStyle();

  menuScreenButtons_ButtonsText = loadShape("menuScreenButtons_ButtonsText.svg");
  menuScreenButtons_ButtonsText.disableStyle();
  menuScreenButtons_ButtonsText_onlyOneCam = loadShape("menuScreenButtons_ButtonsText_onlyOneCam.svg");
  menuScreenButtons_ButtonsText_onlyOneCam.disableStyle();

  menuScreenButtons_Lines = loadShape("menuScreenButtons_Lines.svg");
  menuScreenButtons_Lines.disableStyle();

  // ------------------------ create buttons
  createButtons();
  // ------------------------ make preview shape lists
  // create preview triangle lists AFTER createButtons, 
  // because they need the camHeight which is set in createButtons
  makePreviewShapeLists();
} // end void setup()





// --------------------------------------------------------------------------------
// DRAW
// --------------------------------------------------------------------------------
void draw() {

  if (camShouldStart) {  // only once, read parameters file there
    setCamParameters();
    // -------------------- start cam
    cam.start(); // if no parameters file exits, then the cam starts with default cam: front
    camShouldStart = false;
    setCamButtonStates();
  }
  // --------------------- switch cam
  if (camSwitchAfterFrames >= 0) {
    camSwitchAfterFrames -= 1;
    if (camSwitchAfterFrames==0) {
      switchCam();
    } // end if (camSwitchAfterFrames==0)
  } // end if (camCanSwitch)

  // ----------------------------------------
  // MODE START_SCREEN
  // ----------------------------------------
  if (mode==Mode.START_SCREEN) {
    drawBackground();
    // --------------------- draw rotating ellipses for the symbol
    pushMatrix();
    float sx = width/2.;
    float sy = height/2. - height / 12.; // 120
    translate(sx, sy);
    for (int i=0; i<symbolNum; i++) {
      symbols[i].display();
    }
    popMatrix();

    // --------------------- text "ELEMENTS" with gradient color
    textAlign(CENTER, CENTER);
    textFont(myFont, textSize_200);

    color fromColor = color(187, 66, 87);
    color toColor = color(149, 69, 92);

    String theText = "ELEMENTS";
    float fontX = width/2. - 3.5 * textSpacing_170; // there are 7 spaces in the word elements
    float fontY =  height * 0.4;
    for (int i = 0; i < theText.length(); i++) {
      float percentage = map(i, 0, theText.length()-1, 0., 1.);
      color letterColor = lerpColor(fromColor, toColor, percentage);  
      fill( hue(letterColor), saturation(letterColor), brightness(letterColor) );
      text(theText.charAt(i), fontX, fontY);
      fontX += textSpacing_170;
    } 

    // --------------------- text "android experiment"
    strokeWeight(strokeWeight_2); 
    fill( getBlackOrOpposite() );
    noStroke();
    shape( startScreenAndroidExperiment, 0, 0, width, height );
    // --------------------- draw boxes around buttons
    stroke( getBlackOrOpposite() );
    noFill();
    shape( startScreenButtons_Boxes, 0, 0, width, height );
    // --------------------- draw text inside buttons
    fill( getBlackOrOpposite() );
    noStroke();
    shape( startScreenButtons_Text, 0, 0, width, height ); 
  } // end if (mode==Mode.START_SCREEN)

  // ----------------------------------------
  // MODE EMPTY_CREATE_SCREEN: dotted line is shown to indicate mirroring, access menu button fades out
  // ----------------------------------------
  if (mode==Mode.EMPTY_CREATE_SCREEN) {
    drawBackground();
    // --------------------- draw dotted line
    stroke( getBlackOrOpposite() );
    noFill();
    drawDottedLine(width/2., 0, width/2., height, 50); // fromX, toX, fromY, toY, steps
    // --------------------- menu access button
    menuButtonAccessMenu.display();
    fadeAccessMenuButton();
  }

  // ----------------------------------------
  // MODE CREATE_SCREEN: screen for drawing shapes
  // ----------------------------------------
  if (mode==Mode.CREATE_SCREEN) {
    // -------------------- if no shapes are crated yet, draw background, dotted line and access menu button
    if (theShapes.size() == 0) {
      drawBackground();
      // --------------------- draw dotted line
      stroke( getBlackOrOpposite() );
      noFill();
      drawDottedLine(width/2., 0, width/2., height, 50); // fromX, toX, fromY, toY, steps
      // --------------------- menu access button
      menuButtonAccessMenu.display();
      fadeAccessMenuButton();
    } // end  if(theShapes.size() == 0)

    // ---------------------  when drawing, fill thePoints array list
    fillTheNewPointsArray();
    // ---------------------  show the creation of new points!
    pushMatrix();
    translate(translateX, 0);
    // normal
    showThePointsCreation();
    // mirrored
    scale(-1, 1);
    showThePointsCreation();
    popMatrix();
    // --------------------- draw shapes that are already created
    drawShapes();
    // --------------------- does not need to be displayed
  } // end if (mode==Mode.CREATE_SCREEN)


  // ----------------------------------------
  // MODE MENU_SCREEN
  // ----------------------------------------
  if (mode==Mode.MENU_SCREEN) {
    drawBackground();
    // ------------------ display menu
    displayMenu();
  } // end if (mode==Mode.MENU_SCREEN)


  // ---------------------------------------- 
  // MODE LICENSES_SCREEN
  // ---------------------------------------- 
  if (mode==Mode.LICENSES_SCREEN) {
    drawBackground();
    // --------------------- draw licenses text
    textFont(myFontBold, textSize_40); 
    textAlign(TOP, LEFT);
    fill( getDarkGreyOrOpposite() );

    float licensesTextY = textBorder;
    for (int i=0; i< justFewLinesOfLicensesText.length; i++) {
      text(justFewLinesOfLicensesText[i], textBorder, licensesTextY, width - 3 * textBorder, height);
      licensesTextY += height / 32.; // 45
    }

    // --------------------- draw buttons
    menuButtonContinuePlay.display();
    licensesButtonUp.display();
    licensesButtonDown.display();

    // --------------------- UP or DOWN buttons pressed next to licenses text
    if (mousePressed) {
      // --------------------- button UP
      if ( licensesButtonUp.overRect() ) {
        if (licensesStartIndex > 0) {
          licensesStartIndex -= 1;
        }
        readLicensesTextAndChooseLines();
      } // end if ( licensesButtonUp.overRect() )
      // --------------------- button DOWN
      if ( licensesButtonDown.overRect() ) {

        if (licensesStartIndex < (licenses.length - 1) - ( (numberOfLicensesLines * 2) - 1 ) ) {
          licensesStartIndex += 1;
        }
        readLicensesTextAndChooseLines();
      } // end if ( licensesButtonDown.overRect() )
    } // end if mousePressed()
  } // end  if (mode==Mode.LICENSES_SCREEN)
} // end void draw()


// --------------------------------------------------------------------------------
void readLicensesTextAndChooseLines() {
  for (int i = licensesStartIndex; i< licensesStartIndex + (numberOfLicensesLines * 2)-1; i++) {
    justFewLinesOfLicensesText[i - licensesStartIndex] = licenses[i];
    justFewLinesOfLicensesText[i - licensesStartIndex + 1] = ""; // empty line for linebreaks
  }
}


// --------------------------------------------------------------------------------
void importParameters() {
  reader = createReader(parametersFile);
  if (reader == null) {
    parametersExist = false;
    return;
  }
  else {
   // println(">>>>>>>>>> PARAMETERS EXIST !!!");
   parametersExist = true;
  }

  String line;
  try {
    line = reader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }

  if (line != null) {
    String[] pieces = split(line, ",");
    
    param1_speedScrollbar = float(pieces[0]);
    param2_rotationScrollbar = float(pieces[1]);
    param3_frontCam = float(pieces[2]);
    param4_shapeRounded = float(pieces[3]);
    param5_shapeFilled = float(pieces[4]);
    param6_shapeClosed = float(pieces[5]);
    param7_whiteBackground = float(pieces[6]);
    param8_backCamFlipped = float(pieces[7]);
    param9_frontCamFlipped = float(pieces[8]);
  }
  try {
    reader.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

} // end void importParameters()


// --------------------------------------------------------------------------------
void setParametersValues() {
  // -------------------- set initial values according to parameters file:
  if (parametersExist) {
    if (param4_shapeRounded == 1) {
      shapeRounded = true;
    }
    else {
      shapeRounded = false;
    }

    if (param5_shapeFilled == 1) {
      shapeFilled = true;
    }
    else {
      shapeFilled = false;
    }

    if (param6_shapeClosed == 1) {
      shapeClosed = true;
    }
    else {
      shapeClosed = false;
    }

    if (param7_whiteBackground == 1) {
      whiteBackground = true;
    }
    else {
      whiteBackground = false;
    }

    if (param8_backCamFlipped == 1) {
      backCamFlipped = true;
    }
    else {
      backCamFlipped = false;
    }

    if (param9_frontCamFlipped == 1) {
      frontCamFlipped = true;
    }
    else {
      frontCamFlipped = false;
    }

  } // end if (parametersExist), if no parameters exist, then the initial values from the global variables are taken
} // end void setParametersValues()


// --------------------------------------------------------------------------------
void updateParameters() {

  param1_speedScrollbar = speedScrollbar.getPos();
  param2_rotationScrollbar = rotationScrollbar.getPos();
  param3_frontCam = menuToggleButtonHCam.topRadioButton.getEnabledFloat(); 

  if (shapeRounded) {
    param4_shapeRounded = 1.;
  }
  else {
    param4_shapeRounded = 0.;
  }

  if (shapeFilled) {
    param5_shapeFilled = 1.;
  }
  else {
    param5_shapeFilled = 0.;
  }

  if (shapeClosed) {
    param6_shapeClosed = 1.;
  }
  else {
    param6_shapeClosed = 0.;
  }

  if (whiteBackground) {
    param7_whiteBackground = 1.;
  }
  else {
    param7_whiteBackground = 0.;
  }

  if (backCamFlipped) {
    param8_backCamFlipped = 1.;
  }
  else {
    param8_backCamFlipped = 0.;
  }


  if (frontCamFlipped) {
    param9_frontCamFlipped = 1.;
  }
  else {
    param9_frontCamFlipped = 0.;
  }
/*
  println(
  "changed param 1 to: " + param1_speedScrollbar + 
    " and param2_rotationScrollbar to: " + param2_rotationScrollbar + 
    " front cam set to: " + param3_frontCam +
    " shapeRounded is set to: " + param4_shapeRounded +
    " shapeFilled is set to: " + param5_shapeFilled + 
    " shapeClosed is set to: " + param6_shapeClosed + 
    " whiteBackground is set to: " + param7_whiteBackground +
    " backCamFlipped is set to: " + param8_backCamFlipped +
    " frontCamFlipped is set to: " + param9_frontCamFlipped 
    ); 
  */

  // create new file
  output = createWriter(parametersFile);
  output.println(param1_speedScrollbar + 
    "," + param2_rotationScrollbar +
    "," + param3_frontCam + 
    "," + param4_shapeRounded + 
    "," + param5_shapeFilled +
    "," + param6_shapeClosed +
    "," + param7_whiteBackground +
    "," + param8_backCamFlipped +
    "," + param9_frontCamFlipped
    );

  output.close(); // writes the remaining data to the file & finishes the file
} // end void updateParameters()


// --------------------------------------------------------------------------------
void setValuesRelativeToDeviceHeightOrWidth() {
  // ------------------------------------------- 
  // VALUES RELATIVE to the HEIGHT or WIDTH of the device
  // also known as "yay for magic numbers"
  // -------------------------------------------

  // -------------------- STROKES
  strokeWeight_2 = height / 720.; // 2
  strokeWeight_4 = height / 360. ; // 4
  strokeWeight_6 = height / 240. ; // 6
  strokeWeight_8 = height / 180. ; // 8
  strokeWeight_10 = height / 144.;  // 10

  // -------------------- TEXT
  textSize_40 = height / 36.; // 40
  textSize_60 = height / 24.; // 60
  textSize_100 = height / 14.4; // 100
  textSize_200 = height / 7.2; // 200
  
  // -------------------- for spacing "ELEMENTS" on start screen
  textSpacing_170 = height/8.4706; // 170
  
  // -------------------- for licenses text
  textBorder = height/9.6; // 150 

  // -------------------- for empty create screen
  dottedLineEllipseDiameter = height/360.; // 4;

  // -------------------- distForDrawingNewPoints
  distForDrawingNewPoints = height / 9.6; // 150

  // -------------------- start screen
  startScreenButtonW = width / 2.4876; // 970
  startScreenButtonH = height / 7.2; // 200

  // -------------------- menu screen: toggle buttons
  menuToggleButtonW = width / 6.0325; // 400
  menuToggleButtonH =  height / 7.8261; // 184
  
  menuItemsLeftX = width / 12.3744; // 195; 
  menuItemsMiddleX = width / 1.9554; // 1234;

  menuButtonsLeftColumnX = width / 2.0380; // 1184;
  menuButtonsRightColumnX = width / 1.4078; // 1714;
  menuButtonsTopRowY =  height / 4.1261; // 349;  
  menuButtonsBottomRowY = height / 2.3529; // 612;

  licensesButtonW =  width / 24.13; // 100
  licensesButtonH =   height / 7.2; // 200

  // -------------------- menu screen: scrollbars
  scrollbarWidth = width * 0.35;
  scrollbarHeight = height / 12.; // 120
  speedScrollbarY = height / 3.3724; // 427
  rotationScrollbarY = height / 2.2188 ; // 649;

  // -------------------- menu screen: cam preview
  camWidth = width / 8.8066; // 274
  camHeight = (camWidth / 4. ) * 3.;
  if (!onlyOneCam) {
    camX = menuItemsLeftX + scrollbarWidth - camWidth + height / 241.3;  // + 10
  }
  else {
    camX = menuItemsLeftX + scrollbarWidth/2. - camWidth/2. + width / 344.7143;  // + 7
  }
  camY = height / 1.3358; // 1078
} // end void setValuesRelativeToDeviceHeight()


// --------------------------------------------------------------------------------
// CREATE BUTTONS
// --------------------------------------------------------------------------------
void createButtons() {
   // another "yay for magic numbers...
   
  // -------------------- start screen button: start now
  float startScreenButtonStartNowX = menuItemsLeftX;
  float startScreenButtonStartNowY = height*0.765; // 1882
  startScreenButtonStartNow = new Button(startScreenButtonStartNowX, startScreenButtonStartNowY, startScreenButtonW, startScreenButtonH );
  startScreenButtonStartNow.theText = "START NOW";

  // -------------------- start screen button: settings
  float startScreenButtonSettingsX = width - menuItemsLeftX - startScreenButtonW;
  float startScreenButtonSettingsY = startScreenButtonStartNowY; 
  startScreenButtonSettings = new Button(startScreenButtonSettingsX, startScreenButtonSettingsY, startScreenButtonW, startScreenButtonH );
  startScreenButtonSettings.theText = "SETTINGS";

  // -------------------- create screen button: access menu
  float settingsButtonGapX = width / 60.325; // 40;
  float settingsButtonGapY = height / 36.; // 40;

  float accessMenuButtonSize = height / 10.2857; // 140
  float menuButtonAccessMenuX = width - accessMenuButtonSize  - settingsButtonGapX * 0.8;
  float menuButtonAccessMenuY = 0 + settingsButtonGapY;
  menuButtonAccessMenu = new Button(menuButtonAccessMenuX, menuButtonAccessMenuY, accessMenuButtonSize, accessMenuButtonSize );
  menuButtonAccessMenu.theText = "ACCESS MENU";

  // -------------------- scrollbar speed
  float speedScrollbarX = menuItemsLeftX;
  float speedScrollbarWidth = scrollbarWidth; 
  float speedScrollbarHeight = scrollbarHeight;
  speedScrollbar = new Scrollbar(speedScrollbarX, speedScrollbarY, speedScrollbarWidth, speedScrollbarHeight, 2, "SPEED");
  speedScrollbar.theText = "SPEED";

  // -------------------- scrollbar rotation
  float rotationScrollbarX = menuItemsLeftX;
  float rotationScrollbarWidth = speedScrollbarWidth;
  float rotationScrollbarHeight = speedScrollbarHeight;
  rotationScrollbar = new Scrollbar(rotationScrollbarX, rotationScrollbarY, rotationScrollbarWidth, rotationScrollbarHeight, 2, "ROTATION");
  rotationScrollbar.theText = "ROTATION";

  // ------------------ menu button: cam front or back
  float menuToggleButtonHCamX = menuItemsLeftX - (width / 48.26); // 50  
  float menuToggleButtonHCamY = height / 1.3662; // 1054 
  float menuToggleButtonHCamWidth = width / 6.5216; // 370, bit less wide than the other toggle buttons
  float menuToggleButtonHCamHeight = height / 7.8261; // 184
  menuToggleButtonHCam = new ButtonToggleRadioButtons(menuToggleButtonHCamX, menuToggleButtonHCamY, menuToggleButtonHCamWidth, menuToggleButtonHCamHeight);

  // -------------------- menu button: flip cam

  float menuButtonFlipCamX;
  float menuButtonFlipCamY = height / 1.3714; // 1050
  float  menuButtonFlipCamSize = height / 10.2857; // 140, same as cross button
  if (!onlyOneCam) {
    menuButtonFlipCamX = width / 3.8301; // 630
  }
  else { // onlyOneCam
    menuButtonFlipCamX = width / 7.3121; // 330
  }

  menuButtonFlipCam = new Button(menuButtonFlipCamX, menuButtonFlipCamY, menuButtonFlipCamSize, menuButtonFlipCamSize);
  menuButtonFlipCam.theText= "FLIP CAMERA";

  // -------------------- menu button: round or pointy
  menuToggleButtonShapeRoundedOrPointy = new ButtonToggleRadioButtons(menuButtonsLeftColumnX, menuButtonsTopRowY, menuToggleButtonW, menuToggleButtonH );
  if (!shapeRounded) {
    menuToggleButtonShapeRoundedOrPointy.topRadioButton.setEnabled(true);
    menuToggleButtonShapeRoundedOrPointy.bottomRadioButton.setEnabled(false);
  }
  else {
    menuToggleButtonShapeRoundedOrPointy.topRadioButton.setEnabled(false);
    menuToggleButtonShapeRoundedOrPointy.bottomRadioButton.setEnabled(true);
  }

  // -------------------- menu button: filled or outlined
  menuToggleButtonShapeFilledOrOutlined = new ButtonToggleRadioButtons(menuButtonsRightColumnX, menuButtonsTopRowY, menuToggleButtonW, menuToggleButtonH );
  if (shapeFilled) {
    menuToggleButtonShapeFilledOrOutlined.topRadioButton.setEnabled(true);
    menuToggleButtonShapeFilledOrOutlined.bottomRadioButton.setEnabled(false);
  }
  else {
    menuToggleButtonShapeFilledOrOutlined.topRadioButton.setEnabled(false);
    menuToggleButtonShapeFilledOrOutlined.bottomRadioButton.setEnabled(true);
  }

  // -------------------- menu button: closed or open
  menuToggleButtonShapeClosedOrOpen = new ButtonToggleRadioButtons(menuButtonsLeftColumnX, menuButtonsBottomRowY, menuToggleButtonW, menuToggleButtonH );
  if (!shapeClosed) {
    menuToggleButtonShapeClosedOrOpen.topRadioButton.setEnabled(true);
    menuToggleButtonShapeClosedOrOpen.bottomRadioButton.setEnabled(false);
  }
  else {
    menuToggleButtonShapeClosedOrOpen.topRadioButton.setEnabled(false);
    menuToggleButtonShapeClosedOrOpen.bottomRadioButton.setEnabled(true);
  }

  // -------------------- menu button: BG White or BG black
  menuToggleButtonBgWhiteOrBlack = new ButtonToggleRadioButtons(menuButtonsRightColumnX, menuButtonsBottomRowY, menuToggleButtonW, menuToggleButtonH );
  if (whiteBackground) {
    menuToggleButtonBgWhiteOrBlack.topRadioButton.setEnabled(true);
    menuToggleButtonBgWhiteOrBlack.bottomRadioButton.setEnabled(false);
  }
  else {
    menuToggleButtonBgWhiteOrBlack.topRadioButton.setEnabled(false);
    menuToggleButtonBgWhiteOrBlack.bottomRadioButton.setEnabled(true);
  }

  // -------------------- menu button: licenses
  float menuButtonLicensesX = width / 1.1223; // 2150
  float menuButtonLicensesY = height / 1.125; // 1280
  float menuButtonLicensesWidth = width / 10.0542; // 240
  float menuButtonLicensesHeight =  height / 12.; // 120
  menuButtonLicenses = new Button(menuButtonLicensesX, menuButtonLicensesY, menuButtonLicensesWidth, menuButtonLicensesHeight);
  menuButtonLicenses.theText= "LICENSES";

  // -------------------- licenses button up
  float licensesButtonUpX =  width - width / 8.0433; // 300
  float licensesButtonUpY =  textBorder; 
  licensesButtonUp = new Button(licensesButtonUpX, licensesButtonUpY, licensesButtonW, licensesButtonH );
  licensesButtonUp.theText = "UP";

  // -------------------- licenses button down
  float licensesButtonDownX =  licensesButtonUpX;
  float licensesButtonDownY =  height - textBorder - licensesButtonH;
  licensesButtonDown = new Button(licensesButtonDownX, licensesButtonDownY, licensesButtonW, licensesButtonH );
  licensesButtonDown.theText = "DOWN";

  // -------------------- menu button: cross: restart creating / continue play
  float recreateButtonSize = accessMenuButtonSize;
  float menuButtonContinuePlayX = width - recreateButtonSize - (width / 86.1786); // 28
  float menuButtonContinuePlayY = (height / 51.4286);  // 28

  menuButtonContinuePlay = new Button(menuButtonContinuePlayX, menuButtonContinuePlayY, recreateButtonSize, recreateButtonSize );
  menuButtonContinuePlay.theText = "RESTART CREATING";
} // end void createButtons()


// --------------------------------------------------------------------------------
void makePreviewShapeLists() {
  // -------------------- center, angle, rad
  float cx = width / 1.4589;// 1654
  float cy = height / 1.2522;// 1150
  float angle = 60; // this is always fixed, as the triangle should "stand" on the flat side...
  float rad =  height / 6.6359;// 217
  // --------------------  fill corner points list
  for (int i = 0; i<cornerPointsPreviewShape.length; i++) {
    float x = cx + rad * sin(angle*PI/180);
    float y = cy + rad * cos(angle*PI/180); // set triangle a tiny bit higher, so that it looks better!
    cornerPointsPreviewShape[i] = new PVector(x, y);
    angle += 120;
  }
  // --------------------  first make control points
  int j = 0;
  for (int i=0; i<(cornerPointsPreviewShape.length-1); i++) {
    PVector cpFrom = cornerPointsPreviewShape[i];
    PVector cpTo = cornerPointsPreviewShape[i+1];
    float dx = cpTo.x-cpFrom.x;
    float dy = cpTo.y-cpFrom.y;
    ctrPreviewShape[j] = new PVector(cpFrom.x+dx/3., cpFrom.y+dy/3.);
    ctrPreviewShape[j+1] = new PVector(cpFrom.x+2*dx/3., cpFrom.y+2*dy/3.);
    j += 2;
  }
  PVector last = cornerPointsPreviewShape[2];
  PVector first = cornerPointsPreviewShape[0];
  float dx = first.x-last.x;
  float dy = first.y-last.y;
  ctrPreviewShape[j] = new PVector(last.x + dx/3., last.y + dy/3.);
  ctrPreviewShape[j+1] = new PVector(last.x + 2*dx/3., last.y + 2*dy/3.);

  // -------------------- then make anchor points
  PVector firstCtr = ctrPreviewShape[0]; // first ctr point
  PVector lastCtr = ctrPreviewShape[ ctrPreviewShape.length-1 ]; // last ctr point
  anchPreviewShape[0] = new PVector( (firstCtr.x + lastCtr.x) / 2., ( firstCtr.y + lastCtr.y ) / 2.);
  anchPreviewShape[anchPreviewShape.length-1] = new PVector(anchPreviewShape[0].x, anchPreviewShape[0].y); // last point is the same as first point
  // calc rest of the points
  int k = 1;
  for (int i = 1; i<(anchPreviewShape.length-1); i++) {
    anchPreviewShape[i] = new PVector( ( ctrPreviewShape[k].x + ctrPreviewShape[k+1].x) / 2., ( ctrPreviewShape[k].y + ctrPreviewShape[k+1].y ) / 2.); 
    k += 2;
  }
}  // end void makePreviewShapeLists()


// --------------------------------------------------------------------------------
void setCamButtonStates() {
  // -------------------- set button states
  if ( cam.getCameraID() == 1) { // front cam
    menuToggleButtonHCam.topRadioButton.setEnabled(true);
    menuToggleButtonHCam.bottomRadioButton.setEnabled(false);
  }
  if ( cam.getCameraID() == 0) { // back cam
    menuToggleButtonHCam.topRadioButton.setEnabled(false);
    menuToggleButtonHCam.bottomRadioButton.setEnabled(true);
  }
} // end void setCamButtonStates()

// --------------------------------------------------------------------------------
void setCamParameters() {
  // -------------------- read parameters values for the camera if they exist
  if (parametersExist) {
    if (!onlyOneCam) {
      if (param3_frontCam == 1.) {
        cam.setCameraID(1); // front camera
      }
      else {
        cam.setCameraID(0); // back camera
      }
    }
    else {
      cam.setCameraID(0); // back camera
    }
  } 
  else { // no parameters, default
    if (onlyOneCam) {
      cam.setCameraID(0); // backCamera
    }
    else {
      cam.setCameraID(1); // frontCamera
    }
  }// end if (parametersExist)
} // end void setCamParameters()


// --------------------------------------------------------------------------------
void switchCam() {
  if ( cam.getCameraID() == 0) {
    cam.stop();
    cam.setCameraID(1); // front camera
    cam.start();
  } 
  else { // cam.getCameraID() == 1
    cam.stop();
    cam.setCameraID(0); // back cam
    cam.start();
  } // end if ( cam.getCameraID() == 0)
} // end void switchCam(){


// --------------------------------------------------------------------------------
void drawBackground() {
  noStroke();
  fill( getWhiteOrOpposite() );
  rect(0, 0, width, height);
} // end void drawBackground()


// ------------------------------------------------------------------------
void drawDottedLine(float fromX, float fromY, float toX, float toY, int steps) {

  strokeWeight(strokeWeight_2);
  for (int i = 0; i <= steps; i++) {
    float x = lerp( fromX, toX, i/float(steps) );
    float y = lerp( fromY, toY, i/float(steps) );
    if (i%2==1) {
      float prevX = lerp( fromX, toX, (i-1)/float(steps) );
      float prevY = lerp( fromY, toY, (i-1)/float(steps) );
      // line(x, y, prevX, prevY);
      ellipse(x, y, dottedLineEllipseDiameter, dottedLineEllipseDiameter);
    }
  }
} // end void drawDottedLine(float fromX, float fromY, float toX, float toY, int steps) 


// --------------------------------------------------------------------------------
void fadeAccessMenuButton() {
  if (menuButtonAccessMenuCurrentTrans != menuButtonAccessMenuTargetTrans) {
    menuButtonAccessMenuCurrentTrans = menuButtonAccessMenuCurrentTrans * 0.99 + menuButtonAccessMenuTargetTrans * 0.01;
  }
} // end void fadeAccessMenuButton()


// --------------------------------------------------------------------------------
void fillTheNewPointsArray() {
  float mx = mouseX-translateX;  // -translateX !!!
  float my = mouseY;

  if (mousePressed) {
    // --------------------- adding the very first point _once_ to thePoints and to drawingAnchorPoints
    if (!drawing) {
      // --------------------- clearing all drawing lists
      thePoints.clear();
      drawingControlPoints.clear();
      drawingAnchorPoints.clear();
      // --------------------- add the very first point
      thePoints.add( new PVector(mx, my) ); 
      countNumberOfAllCornerPoints++;
      drawingAnchorPoints.add( new PVector(mx, my) );
      // --------------------- current mouse position becomes previous mouse position
      pmx = mx;
      pmy = my;
      drawing = true;
    }  

    else if ( thePoints.size() < maxNumberOfCornerPointsPerShape && countNumberOfAllCornerPoints < maxNumberOfAllCornerPoints) { 
      // drawing true: add all the next points - here it is known that thePoints.size() is > 1 !!!
      PVector lastAdded = thePoints.get(thePoints.size()-1);

      float d = dist(lastAdded.x, lastAdded.y, mx, my);

      if ( d > distForDrawingNewPoints ) { // avoid several points at one spot 
        thePoints.add(new PVector(mx, my));
        countNumberOfAllCornerPoints++;
        // per new thePoints two CP can be added, that lay between the new P and the previous P
        PVector last =       thePoints.get( thePoints.size()-1 );
        PVector nextToLast = thePoints.get( thePoints.size()-2 );
        float dx = last.x - nextToLast.x;
        float dy = last.y - nextToLast.y;
        drawingControlPoints.add( new PVector(nextToLast.x +    dx/3., nextToLast.y +    dy/3.  ) );
        drawingControlPoints.add( new PVector(nextToLast.x + 2*(dx/3.), nextToLast.y + 2*(dy/3.) ) );

        // when there are 3 or more thePoints, then new APs can be made inbetween the two CPs that lay around the next to last P
        if (thePoints.size() > 2) {
          int index =  thePoints.size()-2; // index of next to last added thePoints
          PVector ctr1 = drawingControlPoints.get( (index*2)-1 );
          PVector ctr2 = drawingControlPoints.get( (index*2)   );
          float apX = ctr1.x + ( ctr2.x - ctr1.x ) / 2.;
          float apY = ctr1.y + ( ctr2.y - ctr1.y ) / 2.;
          drawingAnchorPoints.add( new PVector(apX, apY) );
        }
        pmx = mx;
        pmy = my;
      } // end if ( d > distForDrawingNewPoints )
    } // end if (!drawing)

    if ( thePoints.size() == maxNumberOfCornerPointsPerShape ) {
      createNewShape();
    }

    removeFirstShape();
  } // end if (mousePressed)
} // end fillTheNewPointsArray()


// --------------------------------------------------------------------------------
void createNewShape() {
  // create a new shape out of thePoints list and set drawing to false
  if (thePoints.size() > 1 ) { // at least 2 points are needed to form a shape
    theShapes.add( new TheShape(thePoints) );
  }
  thePoints.clear();
  drawing = false; // clears thePoints next time the mouse is pressed

  if (theShapes.size() == maxNumberOfShapes) {
    removeFirstShape();
  }
}


// --------------------------------------------------------------------------------
void removeFirstShape() {
  // --------------- delete first shape if there are too many points in all the shapes together
  if ( ( countNumberOfAllCornerPoints >= maxNumberOfAllCornerPoints ||  theShapes.size() == maxNumberOfShapes ) && theShapes.size() > 0 ) {
    // --------------------- delete first shape
    int numCornerPointsOfFirstShape = theShapes.get(0).cornerPoints.size();
    countNumberOfAllCornerPoints -= numCornerPointsOfFirstShape;
    theShapes.remove(0);
  }
}


// --------------------------------------------------------------------------------
void restartCreateShapes() {
  drawBackground();
  // --------------------- clear all lists
  theShapes.clear();
  thePoints.clear();
  drawing = false;
  // ---------------------restart fade out access menu button
  menuButtonAccessMenuCurrentTrans = 255;
  menuButtonAccessMenuTargetTrans = 0;

  mode = Mode.EMPTY_CREATE_SCREEN;
} // end void restartCreateShapes()


// --------------------------------------------------------------------------------
void showThePointsCreation() {

  if (thePoints.size() != 0) {

    // --------------------- set colors
    if (cam.isStarted) {
      if (shapeFilled) {
        stroke( getBlackOrOpposite(), 100 );
        // no fill, as it does not look good...
      } 
      else { // shape outlined
        stroke( getCurrentCamColor() );
      } // end else if (shapeFilled)
    }
    else { // cam not active
      if (shapeFilled) {
        stroke( getBlackOrOpposite(), 100 );
      }
      else { // shape outlined
        stroke( getBlackOrOpposite() );
      } // end if (!shapeFilled)
    } // end if (cam.isStarted)

    // even if shapeFilled is true, it does not look good when the shape is already filled WHILE drawing !!!
    // so there is only stroke, no matter if the shape is filled or not
    noFill();
    strokeWeight(strokeWeight_2);


    if (shapeRounded) {

      if (shapeClosed) {
        // draw round line: with one bezierVertex less at the start if the shape 
        // will be closed once the drawing is finished!
        if (drawingAnchorPoints.size() > 1 && drawingControlPoints.size()>2) {
          beginShape();
          vertex(drawingAnchorPoints.get(1).x, drawingAnchorPoints.get(1).y); // start at second point
          int j = 2;
          for (int i = 2; i<drawingAnchorPoints.size(); i++) {
            bezierVertex(drawingControlPoints.get(j).x, drawingControlPoints.get(j).y, drawingControlPoints.get(j+1).x, drawingControlPoints.get(j+1).y, drawingAnchorPoints.get(i).x, drawingAnchorPoints.get(i).y);
            j += 2;
          }
          endShape();
        } // end if (drawingAnchorPoints.size() > 1 && drawingControlPoints.size()>2)
      }

      else { // shapen open
        // draw round line, all vertices
        beginShape();
        vertex(drawingAnchorPoints.get(0).x, drawingAnchorPoints.get(0).y);
        int j = 0;
        for (int i = 1; i<drawingAnchorPoints.size(); i++) {
          bezierVertex(drawingControlPoints.get(j).x, drawingControlPoints.get(j).y, drawingControlPoints.get(j+1).x, drawingControlPoints.get(j+1).y, drawingAnchorPoints.get(i).x, drawingAnchorPoints.get(i).y);
          j += 2;
        }
        endShape();
      } // end if(shapeClosed)
    }
    else { // shape pointy

      // draw pointy line
      beginShape();
      for (int i=0; i< thePoints.size(); i++ ) {
        float px = thePoints.get(i).x;
        float py = thePoints.get(i).y;
        vertex(px, py);
      }
      endShape();
    } // end  if(shapeRounded){
  } // end if (thePoints.size() != 0)
} // end void showThePointsCreation()


// --------------------------------------------------------------------------------
// draw shapes mirrored along center line
void drawShapes() {
  if (theShapes.size()!= 0) {
    pushMatrix();
    translate(translateX, 0);
    for (int i=0; i<theShapes.size(); i++) {
      theShapes.get(i).update();
    }
    scale(-1, 1);
    for (int i=0; i<theShapes.size(); i++) {
      theShapes.get(i).update();
    }
    popMatrix();
  } // end if(theShapes.size()!= 0)
} // end void drawShapes()


// --------------------------------------------------------------------------------
void displayMenu() { 
  // -------------------- svg file titles texts
  noStroke();
  fill( getBlackOrOpposite() );
  shape(menuScreenButtons_Titles, 0, 0, width, height);
  // -------------------- svg file texts
  fill( getDarkGreyOrOpposite() );

  if (!onlyOneCam) {
    shape(menuScreenButtons_ButtonsText, 0, 0, width, height);
  }
  else {
    shape( menuScreenButtons_ButtonsText_onlyOneCam, 0, 0, width, height);
  }
  // -------------------- svg file button lines
  strokeWeight( strokeWeight_2 );
  stroke( getLightGreyOrOpposite() );
  noFill();
  shape(menuScreenButtons_Lines, 0, 0, width, height);
  // -------------------- speed scrollbar: update and display
  speedScrollbar.update();
  speedScrollbar.display();
  // -------------------- rotation scrollbar: update and display
  rotationScrollbar.update();
  rotationScrollbar.display();
  // -------------------- toggle buttons
  menuToggleButtonShapeRoundedOrPointy.display(); // pointy and rounded
  menuToggleButtonShapeFilledOrOutlined.display(); // filled and outlined
  menuToggleButtonShapeClosedOrOpen.display(); // open and closed
  menuToggleButtonBgWhiteOrBlack.display(); // bg white and bg black
  if (!onlyOneCam) {
    menuToggleButtonHCam.display(); // cam front and back
  }
  // -------------------- cam preview
  displayCamPreview();
  menuButtonFlipCam.display();
  // ------------------ shape preview
  displayPreviewShape();
  // -------------------- cross button to exit menu screen
  menuButtonContinuePlay.display();
  // -------------------- licenses button
  menuButtonLicenses.display();
} // end void displayMenu()


// --------------------------------------------------------------------------------
void displayCamPreview() {
  pushMatrix();
  translate(camX, camY);

  // -------------------- draw cam preview
  if (cam.getCameraID() == 0) { // back cam
    if (backCamFlipped) {
      translate(0, camHeight); 
      scale(1, -1);
    }
  }

  if (cam.getCameraID() == 1) { // front cam needs flipping, ketai doesn't do this...
    if (frontCamFlipped) {
      translate(0, camHeight); 
      scale(1, -1);
    }
  }

  noStroke();
  image(cam, 0, 0, camWidth, camHeight); 

  // -------------------- draw border around cam preview
  strokeWeight(strokeWeight_2); 
  noFill();
  stroke( getBlackOrOpposite() );
  rect(0, 0, camWidth, camHeight);

  popMatrix();
} // end void displayCamPreview()


// --------------------------------------------------------------------------------
void displayPreviewShape() {

  // -------------------- shape rounded:
  if (shapeRounded) {

    if (shapeFilled) { // shape filled
      fill(getCurrentCamColor() );  // fill: cam color
      stroke( getBlackOrOpposite(), 180 );
    }
    else { // shape outlined
      noFill();
      stroke( getCurrentCamColor() ); // outline: cam color
    }
    // -------------------- draw rounded shape:
    strokeWeight(strokeWeight_10);
    drawRoundPreviewShape();
    // -------------------- and also draw pointy shape, but thinner lines  
    noFill();
    strokeWeight(strokeWeight_2);
    stroke( getBlackOrOpposite(), 100 );
    drawPointyPreviewShape();
  }
  else { 
    // -------------------- shape pointy:
    if (shapeFilled) { // shape filled
      fill(getCurrentCamColor());
      stroke( getBlackOrOpposite(), 180 );
    }
    else { // shape outlined
      noFill();
      stroke( getCurrentCamColor() );
    }
    // -------------------- draw pointy shape
    strokeWeight(strokeWeight_10);
    drawPointyPreviewShape();
  } // end if(shapeRounded)
} // end void displayPreviewShape()


// --------------------------------------------------------------------------------
void drawRoundPreviewShape() {
  if (shapeClosed) {
    beginShape(); 
    vertex(anchPreviewShape[0].x, anchPreviewShape[0].y);
    int j = 0;
    for (int i = 1; i<anchPreviewShape.length; i++) {
      PVector cp1 = ctrPreviewShape[j];
      PVector cp2 = ctrPreviewShape[j+1];
      PVector ap =  anchPreviewShape[i];
      bezierVertex( cp1.x, cp1.y, cp2.x, cp2.y, ap.x, ap.y );
      j += 2;
    }
    endShape();
  }
  else { // shapeClosed is false
    beginShape(); 
    vertex(anchPreviewShape[0].x, anchPreviewShape[0].y);
    int j = 0;
    for (int i = 1; i<anchPreviewShape.length-1; i++) {
      PVector cp1 = ctrPreviewShape[j];
      PVector cp2 = ctrPreviewShape[j+1];
      PVector ap =  anchPreviewShape[i];
      bezierVertex( cp1.x, cp1.y, cp2.x, cp2.y, ap.x, ap.y );
      j += 2;
    }
    endShape();
  }
} // end void drawRoundPreviewShape()


// --------------------------------------------------------------------------------
void drawPointyPreviewShape() {
  beginShape();
  for (int i = 0; i<cornerPointsPreviewShape.length; i++) {
    vertex(cornerPointsPreviewShape[i].x, cornerPointsPreviewShape[i].y );
  }
  if (shapeClosed) {
    endShape(CLOSE);
  }
  else {
    endShape();
  }
} // end void drawPointyPreviewShape()


// --------------------------------------------------------------------------------
color getBlackOrOpposite() {
  if (whiteBackground) {
    return black;
  }
  else {
    return white;
  }
} // end color getBlackOrOpposite()


// --------------------------------------------------------------------------------
color getWhiteOrOpposite() {
  if (whiteBackground) {
    return white;
  }
  else {
    return black;
  }
}


// --------------------------------------------------------------------------------
color getCurrentCamColor() {
  int numberOfPixels = cam.pixels.length;

  for (int i=0; i<hues.length; i++) {
    hues[i] = 0;
    saturations[i] = 0;
    brightnesses[i] = 0;
  }
  // -------------------- increase number for related color in hues array by one whenever this color is found
  for (int i = 0; i < numberOfPixels; i+=100) {
    int pixel = cam.pixels[i];
    int hue = int( hue(pixel) );
    float saturation = saturation(pixel);
    float brightness = brightness(pixel);
    hues[hue] ++;
    saturations[hue] += saturation;
    brightnesses[hue] += brightness;
  }

  // -------------------- find most common hue 
  int hueCount = hues[0]; 
  int hue = 0;
  for (int i = 1; i < hues.length; i++) {
    if (hues[i] > hueCount) {
      hueCount = hues[i];
      hue = i;
    }
  }
  // -------------------- setting targets
  targetHue = hue;
  targetSaturation = saturations[hue] / hueCount;
  targetBrightness = brightnesses[hue] / hueCount;

  if (currentHue != targetHue) {
    currentHue = currentHue * 0.95 + targetHue * 0.05;
  }
  if (currentSaturation != targetSaturation) {
    currentSaturation = currentSaturation * 0.95 + targetSaturation * 0.05;
  }
  if (currentBrightness != targetBrightness) {
    currentBrightness = currentBrightness * 0.95 + targetBrightness * 0.05;
  }

  // -------------------- set current average cam color
  currentAverageCamColor = color(currentHue, currentSaturation, currentBrightness );

  return currentAverageCamColor;
} // end  color getAverageCamColor()


// --------------------------------------------------------------------------------
color getDarkGreyOrOpposite() {
  if (whiteBackground) {
    return darkGrey;
  }
  else {
    return darkGreyOnBlackBg;
  }
} // end color getDarkGreyOrOpposite()


// --------------------------------------------------------------------------------
color getLightGreyOrOpposite() {
  if (whiteBackground) {
    return lightGrey;
  }
  else {
    return lightGreyOnBlackBg;
  }
} // end color getLightGreyOrOpposite()


// --------------------------------------------------------------------------------
color getVeryDarkGreyOrOpposite() {
  if (whiteBackground) {
    return veryDarkGrey;
  }
  else {
    return veryDarkGreyOnBlackBg;
  }
} // end color getVeryDarkGreyOrOpposite()


// --------------------------------------------------------------------------------
// MOUSE PRESSED
// --------------------------------------------------------------------------------
void mousePressed() {

  switch(mode) {
    // ---------------------------------------- 
  case START_SCREEN: 
    // -------------------- start now button
    if (startScreenButtonStartNow.overRect()) {
      mode = Mode.EMPTY_CREATE_SCREEN;
    }
    // -------------------- settings button
    if (startScreenButtonSettings.overRect()) {
      mode = Mode.MENU_SCREEN;
    }
    break;


    // ---------------------------------------- 
  case EMPTY_CREATE_SCREEN:
    // -------------------- access menu button
    if (menuButtonAccessMenu.overRect()) {
      mode = Mode.MENU_SCREEN;
    }
    else { // user clicked somewhere but the access menu button
      // startTime is set when user doubleTaps
      elapsedTime = millis() - startTime;
      if (elapsedTime > 100) {
        mode = Mode.CREATE_SCREEN;
      }
    } // end if (menuButtonAccessMenu.overRect())

    break;

    // ---------------------------------------- 
  case CREATE_SCREEN:
    // -------------------- access menu button
    if (menuButtonAccessMenu.overRect()) {
      drawBackground();
      mode = Mode.MENU_SCREEN;
    }
    break;


    // ----------------------------------------
  case MENU_SCREEN:
    // -------------------- cross button: continue play
    if (menuButtonContinuePlay.overRect()) {
      // when user leaves the menu then the lists of all points should be recreated.
      // in case there were only pointy shapes and now there are round shapes,
      // more points will be needed to draw the spline
      for (int i=0; i<theShapes.size(); i++) {
        ArrayList<PVector> path = theShapes.get(i).cornerPoints;
        theShapes.get(i).makeControlPoints( path );
        theShapes.get(i).makeAnchorPoints( path );
        theShapes.get(i).makeSplinePointsDetailed();
        // get the current values of the sliders to set verticalSpeed and angleSpeed of the shapes
        theShapes.get(i).setVerticalSpeed();
        theShapes.get(i).setAngleSpeed();
      }

      drawBackground();

      if (theShapes.size() > 0) {
        mode = Mode.CREATE_SCREEN;
      }
      else {
        // make access menu button visible again
        menuButtonAccessMenuCurrentTrans = 255;
        menuButtonAccessMenuTargetTrans = 0;
        mode = Mode.EMPTY_CREATE_SCREEN; // this is inside restartCreateShapes
      }
      // avoid slider moving unintentionally when going back to menu screen later
      someScrollbarClicked = false;
    } // end if (menuButtonContinuePlay.overRect())

    // -------------------- flip front or back cam button
    if (menuButtonFlipCam.overRect()) {
      if (cam.getCameraID() == 0) { // back cam
        backCamFlipped = !backCamFlipped;
      } 
      else { // front cam
        frontCamFlipped = !frontCamFlipped;
      }
    }

    // -------------------- cam front or back button
    if (!onlyOneCam) {
      if (menuToggleButtonHCam.overRect()) {
        if ( cam.getCameraID() == 0) { // front

          menuToggleButtonHCam.topRadioButton.setEnabled(true);
          menuToggleButtonHCam.bottomRadioButton.setEnabled(false);
        }
        else { // back
          menuToggleButtonHCam.topRadioButton.setEnabled(false);
          menuToggleButtonHCam.bottomRadioButton.setEnabled(true);
        }
        camSwitchAfterFrames = 2;
      } // end if (menuToggleButtonHCam.overRect())
    } // end if (!onlyOneCam)



    // -------------------- shape rouonded or pointy button
    if (menuToggleButtonShapeRoundedOrPointy.overRect()) {
      shapeRounded = !shapeRounded;
      if (!shapeRounded) {
        menuToggleButtonShapeRoundedOrPointy.topRadioButton.setEnabled(true);
        menuToggleButtonShapeRoundedOrPointy.bottomRadioButton.setEnabled(false);
      }
      else {
        menuToggleButtonShapeRoundedOrPointy.topRadioButton.setEnabled(false);
        menuToggleButtonShapeRoundedOrPointy.bottomRadioButton.setEnabled(true);
      }
    }

    // -------------------- shape filled or outlined button
    if (menuToggleButtonShapeFilledOrOutlined.overRect()) {
      shapeFilled = !shapeFilled;
      if (shapeFilled) {
        menuToggleButtonShapeFilledOrOutlined.topRadioButton.setEnabled(true);
        menuToggleButtonShapeFilledOrOutlined.bottomRadioButton.setEnabled(false);
      }
      else {
        menuToggleButtonShapeFilledOrOutlined.topRadioButton.setEnabled(false);
        menuToggleButtonShapeFilledOrOutlined.bottomRadioButton.setEnabled(true);
      }
    }

    // --------------------- shape open or closed button
    if (menuToggleButtonShapeClosedOrOpen.overRect()) {
      shapeClosed = !shapeClosed;
      if (!shapeClosed) {
        menuToggleButtonShapeClosedOrOpen.topRadioButton.setEnabled(true);
        menuToggleButtonShapeClosedOrOpen.bottomRadioButton.setEnabled(false);
      }
      else {
        menuToggleButtonShapeClosedOrOpen.topRadioButton.setEnabled(false);
        menuToggleButtonShapeClosedOrOpen.bottomRadioButton.setEnabled(true);
      }
    }

    // -------------------- bg white or black button
    if (menuToggleButtonBgWhiteOrBlack.overRect()) {
      whiteBackground = !whiteBackground;

      if (whiteBackground) {
        menuToggleButtonBgWhiteOrBlack.topRadioButton.setEnabled(true);
        menuToggleButtonBgWhiteOrBlack.bottomRadioButton.setEnabled(false);
      }
      else {
        menuToggleButtonBgWhiteOrBlack.topRadioButton.setEnabled(false);
        menuToggleButtonBgWhiteOrBlack.bottomRadioButton.setEnabled(true);
      }
    }

    // -------------------- licenses button
    if (menuButtonLicenses.overRect()) {
      licensesStartIndex = 0;
      readLicensesTextAndChooseLines();
      mode = Mode.LICENSES_SCREEN;
    }
    // -------------------- always update parameters 
    updateParameters();
    break;


    // ----------------------------------------
  case  LICENSES_SCREEN:
    // -------------------- cross button: continue play
    if ( menuButtonContinuePlay.overRect() ) {
      drawBackground();
      mode = Mode.MENU_SCREEN;
    }
    break;
  } // end switch(mode

  println("mousePRESSED: mode: " + mode);
} // end void mousePressed() 


// --------------------------------------------------------------------------------
// MOUSE RELEASED
// --------------------------------------------------------------------------------
void mouseReleased() {
  switch(mode) {
  case CREATE_SCREEN:
    createNewShape();
    // once the first shape is created, clear the background and set transparency of menu access button to 0
    if (theShapes.size()==1 ) {
      menuButtonAccessMenuCurrentTrans = 0;
      menuButtonAccessMenuTargetTrans = 0;
      drawBackground();
    }
    break;
  }
} // end void mouseReleased() 


// -------------------------------------------------------------------------------- ketai
void onDoubleTap(float x, float y)
{
  // start timer for preventing doubleTap to be the first tap on the EMPTY_CREATE_SCREEN
  startTime = millis(); 
  switch(mode) {
  case CREATE_SCREEN:
    // clear screen and all points and shapes and let user restart creating shapes
    countNumberOfAllCornerPoints = 0;
    restartCreateShapes();
    break;
  } // end switch(mode){
}


// -------------------------------------------------------------------------------- ketai
public boolean surfaceTouchEvent(MotionEvent event) {
  // call to keep mouseX, mouseY, etc updated
  super.surfaceTouchEvent(event);

  //forward event to class for processing
  return gesture.surfaceTouchEvent(event);
}


// -------------------------------------------------------------------------------- ketai
void onCameraPreviewEvent()
{
  cam.read();
}


// --------------------------------------------------------------------------------
float getMinFromFloatList( FloatList theFloatList  ) {
  float minVal = theFloatList.get(0);
  for (int i=1; i<theFloatList.size(); i++) {
    if ( theFloatList.get(i) < minVal ) {
      minVal = theFloatList.get(i);
    }
  }
  return minVal;
}


// --------------------------------------------------------------------------------
float getMaxFromFloatList( FloatList theFloatList  ) {
  float maxVal = theFloatList.get(0);
  for (int i=1; i<theFloatList.size(); i++) {
    if ( theFloatList.get(i) > maxVal ) {
      maxVal = theFloatList.get(i);
    }
  }
  return maxVal;
}

