class TheShape {

  // vertical Speed
  float verticalSpeed, oriVerticalSpeed, verticalSpeedLimit, verticalSpeedMin, verticalSpeedMax;

  // angle
  float angle, angleSpeed, oriAngleSpeed, angleSpeedLimit;

  // list of sin values
  FloatList sinLUT = new FloatList();
  float sinLUTindex;

  // bounding box limits
  float left, right, top, bottom;

  // lists for bounding box 
  FloatList xValues = new FloatList(); 
  FloatList yValues = new FloatList();

  // lists for storing points for pointy shape
  ArrayList<PVector> cornerPoints = new ArrayList<PVector>();
  ArrayList<PVector> cornerPointsRotated = new ArrayList<PVector>();

  // lists for storing points for rounded shape
  ArrayList<PVector> splinePoints = new ArrayList<PVector>();
  ArrayList<PVector> splinePointsTransformed = new ArrayList<PVector>();
  PVector[] ctr;  // control points
  PVector[] anch; // anchor points

  boolean emptyPath;

  // vars for the detail of the rounded shapes
  int numSteps = 4;
  int stepCnt = 0;
  // ---------------------------------------- 
  TheShape(ArrayList<PVector> path) {

    if (path.size()>0) { 
      emptyPath = false;
      addThePointsToCornerPointsList();
      makeControlPoints(path);
      makeAnchorPoints(path);
      makeSplinePointsDetailed();
      fillSinLUT();
    } 
    else {
      emptyPath = true;
    }
    // ----------------- vertical speed
    verticalSpeedMin = height / 360.; //  4
    verticalSpeedMax = height / 144.; // 10
    oriVerticalSpeed = random(verticalSpeedMin, verticalSpeedMax);
    setVerticalSpeed();
    // ----------------- angle
    angle = 0;
    oriAngleSpeed = random(3, 5); // num !!! was 3, 9
    setAngleSpeed();
  }// end constructor


  // ---------------------------------------- 
  void addThePointsToCornerPointsList() {
    for (int i=0; i< thePoints.size(); i++) {
      cornerPoints.add( new PVector(thePoints.get(i).x, thePoints.get(i).y)  );
    }
  } // end void addThePointsToCornerPointsList()


  // ---------------------------------------- 
  void makeControlPoints(ArrayList<PVector> p) {
    if (emptyPath) { 
      return;
    }
    if (shapeClosed) {
      ctr = new PVector[p.size()*2];
    } 
    else {
      ctr = new PVector[(p.size()-1)*2];
    }
    int j = 0;
    for (int i=0; i<(p.size()-1); i++) {
      PVector from = p.get(i);
      PVector to = p.get(i+1);
      float dx = to.x - from.x;
      float dy = to.y - from.y;
      ctr[j] = new PVector( from.x+ dx/3., from.y + dy/3. );
      ctr[j+1] = new PVector( from.x+ 2*(dx/3.), from.y + 2*(dy/3.) );
      j += 2;
    }
    if (shapeClosed) {  // add two more points
      PVector last = p.get(p.size()-1);
      PVector first = p.get(0);
      float dx = first.x-last.x;
      float dy = first.y-last.y;
      ctr[j]   = new PVector(last.x +    dx/3., last.y +    dy/3.  );
      ctr[j+1] = new PVector(last.x + 2*(dx/3.), last.y + 2*(dy/3.) );
    }
  } // end void makeControlPoints(ArrayList<PVector> p)


  // ---------------------------------------- 
  void makeAnchorPoints(ArrayList<PVector> p) {
    if (emptyPath) { 
      return;
    }

    if (shapeClosed) {
      anch = new PVector[p.size()+1];
      PVector firstCtr = ctr[0];
      PVector lastCtr =  ctr[ctr.length-1];
      // first and last AP are the same
      anch[0] = new PVector( (firstCtr.x + lastCtr.x) / 2., (firstCtr.y + lastCtr.y) / 2. );
      anch[anch.length-1] = new PVector(anch[0].x, anch[0].y);
    } 
    else {
      anch = new PVector[p.size()];
      // first and last AP correspond with first and last corner points
      anch[0] = new PVector(p.get(0).x, p.get(0).y);
      anch[anch.length-1] = new PVector(p.get(p.size()-1).x, p.get(p.size()-1).y);
    }

    int j = 1; // starts with second ctr!, leaves out first and last AP
    for (int i = 1; i < anch.length-1; i++) { // starts with second AP, j: loops through second to next to last AP
      PVector from = ctr[j];
      PVector to =   ctr[j+1];
      anch[i] = new PVector( (from.x + to.x) / 2., (from.y + to.y) / 2.);
      j += 2;
    }
  } // end void makeAnchorPoints(ArrayList<PVector> p)


  // ---------------------------------------- 
  void makeSplinePointsDetailed() {

    splinePoints.clear();

    // ----------------- make detailed spline using bezier formula and steps !
    for (int i=0; i<anch.length-1; i++) {
      PVector b1 = anch[i];
      PVector b2 = ctr[ (i*2)    ];
      PVector b3 = ctr[ (i*2) +1 ];
      PVector b4 = anch[i+1];
      stepCnt = 0;
      while (stepCnt < numSteps) {
        // ----------------- calculate new bezierPoints with stepCnt and numSteps and add them to the list !
        PVector newBezierPoint =  getNewBezierPoint(b1, b2, b3, b4);
        splinePoints.add( new PVector( newBezierPoint.x, newBezierPoint.y  ) );
        stepCnt++;
      } // end while (stepCnt < numSteps)
    } // end for (int i=0; i<anch.length-1; i++)

    // ----------------- add very last point
    splinePointsTransformed.clear();

    for (int i=0; i<splinePoints.size(); i++) {
      splinePointsTransformed.add( new PVector() ); // check !!! ???
    }

    // println("splinePoints.size(): " + splinePoints.size() );
    // println("splinePointsTransformed.size(): " + splinePointsTransformed.size() );
  } // end void makeSplinePointsDetailed()


  // ---------------------------------------- 
  void fillSinLUT() {
    float sinCounter = random(360);
    float sinCounterOri = sinCounter;
    float sinCounterSpeed = 0.01;
    while (sinCounter < sinCounterOri+360.) {
      float sinValue = (sin(sinCounter*1) + sin(sinCounter*2) + sin(sinCounter*3)) / 3.; // -1..+1
      sinLUT.append(sinValue);
      sinCounter += sinCounterSpeed;
    }
    sinLUTindex = int( random( sinLUT.size()-1 ) );
  } // end  void fillSinLUT()


  // ---------------------------------------- 
  void setVerticalSpeed() {
    float speedScrollbarValue = map(speedScrollbar.getPos(), -1, +1, +1, -1); // -1..+1 turn around values!
    verticalSpeed = oriVerticalSpeed * speedScrollbarValue;
  } // end void setVerticalSpeed()

  // ---------------------------------------- 
  void setAngleSpeed() {
    float rotationScrollbarValue = map(rotationScrollbar.getPos(), -1, +1, +1, -1); // -1..+1 turn around values!
    angleSpeed = oriAngleSpeed * rotationScrollbarValue;
  } // end void setAngleSpeed()


  // ---------------------------------------- 
  void update() {
    calculateAngle();
    calculatePointsTransformations();
    calculateBoundingBox(); // calculates left, right, top, bottom
    changeX();
    changeY(); // and calculate bounding box! AFTER anchorpoints are updated !!!

    setShapeColorsAccordingToCam();

    strokeWeight(strokeWeight_2);
    if (shapeRounded) {
      drawSplineNew();
    }
    else {
      drawPointyShape();
    } // end  if(shapeRounded){
  } // end void update() {


  // ---------------------------------------- 
  void calculateAngle() {
    angle += angleSpeed;
  } // end void calculateAngle()


  // ---------------------------------------- 
  void calculatePointsTransformations() {
    // ----------------- rotate splinePoints
    PVector transformCenterDetailed = splinePoints.get(0);
    for (int i=0; i<splinePoints.size(); i++) { // rotates p1 around itself...
      PVector pOriDetailed = splinePoints.get(i);
      PVector pTransformedDetailed = splinePointsTransformed.get(i);
      pTransformedDetailed.x = pOriDetailed.x;
      pTransformedDetailed.y = pOriDetailed.y;
      rotatePointAroundPoint( pTransformedDetailed, transformCenterDetailed, angle);
    }

    // ----------------- rotate corner points
    cornerPointsRotated.clear();
    for (int i=0; i<cornerPoints.size(); i++) { // rotates p1 around itself...
      cornerPointsRotated.add(  rotateCopyOfPointAroundPoint(cornerPoints.get(i), cornerPoints.get(0), angle)  );
    }
  } // end calculatePointsTransformations()



  // ---------------------------------------- 
  void calculateBoundingBox() {
    // ----------------- find NEW bounding box for the already rotated shape!
    xValues.clear();
    yValues.clear();
    // ----------------- JUST use corner points for calculating bounding box:
    for (int i=0; i<cornerPointsRotated.size(); i++) {
      xValues.append( cornerPointsRotated.get(i).x );
    }
    for (int i=0; i<cornerPointsRotated.size(); i++) {
      yValues.append( cornerPointsRotated.get(i).y );
    }
    // ----------------- new boundaries
    left = getMinFromFloatList(xValues);  // most left point of all
    right = getMaxFromFloatList(xValues); // most right point
    top = getMinFromFloatList(yValues); // most top point
    bottom = getMaxFromFloatList(yValues); // most bottom point
  } // end void calculateBoundingBox() 


  // ---------------------------------------- 
  void changeX() {
    // TEST SPEED: check !!!
    // do all movements with both the lists: corner points and spline points
    // so that i only have to calculate the bounding box for the corner points...
    float sinValue = sinLUT.get( int(sinLUTindex) );
    if (sinLUTindex < sinLUT.size()-2) {
      float indexInc = map(abs(verticalSpeed), 0, verticalSpeedMax, 0, 0.5); // num !!!
      sinLUTindex += indexInc;
    }
    else {
      sinLUTindex = 0;
    }

    // ----------------- change x position and border check left and right
    if (shapeRounded) {
      // ----------------- splinepoints
      for (int i=0; i<splinePoints.size(); i++) {
        splinePoints.get(i).x +=  sinValue*2;
      }
      // ----------------- add corner points for calculating bounding box
      for (int i=0; i<cornerPoints.size(); i++) {
        cornerPoints.get(i).x +=  sinValue * 2 ;
      }
    } // shape pointy
    else {
      for (int i=0; i<cornerPoints.size(); i++) {
        cornerPoints.get(i).x +=  sinValue * 2 ;
      }
    } //end  if (shapeRounded)


    float boundingBoxWidth = right - left;
    // ----------------- add translateX, because the points are moved translateX to the left when added to thePointsList

      // ----------------- check right and reset cornerPoints or splinePoints
    if ( right+translateX < 0 ) {

      if (shapeRounded) {
        // ----------------- splinepoints
        for (int i=0; i<splinePoints.size(); i++) {
          splinePoints.get(i).x += (width + boundingBoxWidth);
        }
        // ----------------- add corner points for calculating bounding box !!!
        for (int i=0; i<cornerPoints.size(); i++) {
          cornerPoints.get(i).x += (width  + boundingBoxWidth);
        }
      } 
      else {
        for (int i=0; i<cornerPoints.size(); i++) {
          cornerPoints.get(i).x += (width  + boundingBoxWidth);
        }
      }// end if (shapeRounded)
    } // end if ( bottom < 0)


    // ----------------- check left and reset cornerPoints or splinePoints
    if ( left+translateX > width) {

      if (shapeRounded) {
        // ----------------- splinepoints
        for (int i=0; i<splinePoints.size(); i++) {
          splinePoints.get(i).x -= ( width + boundingBoxWidth);
        }
        // ----------------- add corner points for calculating bounding box !!!
        for (int i=0; i<cornerPoints.size(); i++) {
          cornerPoints.get(i).x -= ( width + boundingBoxWidth);
        }
      }
      else { // shape pointy
        for (int i=0; i<cornerPoints.size(); i++) {
          cornerPoints.get(i).x -= ( width + boundingBoxWidth);
        }
      }//end  if (shapeRounded)
    } // end if ( top > height)
  } // end changeX


  // ---------------------------------------- 
  void changeY() {
    // ----------------- change y position and border check top and bottom
    if (shapeRounded) {
      // ----------------- splinepoints
      for (int i=0; i<splinePoints.size(); i++) {
        splinePoints.get(i).y -= verticalSpeed;
      }
      // ----------------- add corner points for calculating bounding box !
      for (int i=0; i<cornerPoints.size(); i++) {
        cornerPoints.get(i).y -= verticalSpeed;
      }
    }
    else { // shape pointy
      for (int i=0; i<cornerPoints.size(); i++) {
        cornerPoints.get(i).y -= verticalSpeed;
      }
    } //end  if (shapeRounded)


    float boundingBoxHeight = bottom - top;
    // ----------------- check bottom and reset cornerPoints or splinePoints
    if ( bottom < 0) {

      if (shapeRounded) {
        // ----------------- spline points
        for (int i=0; i<splinePoints.size(); i++) {
          splinePoints.get(i).y += (height + boundingBoxHeight);
        }
        // ----------------- add corner points for calculating bounding box !
        for (int i=0; i<cornerPoints.size(); i++) {
          cornerPoints.get(i).y += (height + boundingBoxHeight);
        }
      } 
      else { // shape pointy
        for (int i=0; i<cornerPoints.size(); i++) {
          cornerPoints.get(i).y += (height + boundingBoxHeight);
        }
      }//end  if (shapeRounded)
    } // end if ( bottom < 0)


    // ----------------- check top and reset cornerPoints or splinePoints
    if ( top > height) {

      if (shapeRounded) {
        // ----------------- splinepoints
        for (int i=0; i<splinePoints.size(); i++) {
          splinePoints.get(i).y -= (height + boundingBoxHeight);
        }
        // ----------------- add corner points for calculating bounding box !
        for (int i=0; i<cornerPoints.size(); i++) {
          cornerPoints.get(i).y -= (height + boundingBoxHeight);
        }
      } // shape pointy
      else {
        for (int i=0; i<cornerPoints.size(); i++) {
          cornerPoints.get(i).y -= (height + boundingBoxHeight);
        }
      }//end  if (shapeRounded)
    } // end if ( top > height)
  } // end void changeY()


  // ---------------------------------------- 
  void setShapeColorsAccordingToCam() {   
    if (cam.isStarted) {
      if (shapeFilled) {
        stroke( getBlackOrOpposite(), 100 );
        fill(getCurrentCamColor(), 30);
      }
      else {  // shape not filled
        fill( getWhiteOrOpposite(), 10 );
        stroke( getCurrentCamColor(), 255);
      } // end if (shapeFilled)
    }
    else { // cam  not active
      if (shapeFilled) {
        fill( getWhiteOrOpposite(), 100 );
        stroke( getBlackOrOpposite(), 30 );
      }
      else { // !shapeFilled
        fill( getWhiteOrOpposite(), 10 );
        stroke( getBlackOrOpposite(), 255 );
      } // end if (shapeFilled)
    } // end if (cam.isStarted)
  } // end setShapeColorsAccordingToCam()



  // ---------------------------------------- 
  void drawSplineNew() {
    if (emptyPath) { 
      return;
    }

    beginShape();
    for (int i = 0; i<splinePointsTransformed.size(); i++) {
      // PVector from = splinePointsTransformed.get(i);
      // PVector to = splinePointsTransformed.get(i+1);

      //  line( from.x, from.y, to.x, to.y);
      PVector p = splinePointsTransformed.get(i);
      vertex(p.x, p.y);
    }
    if (shapeClosed) {
      endShape(CLOSE);
    }
    else {
      endShape();
    }
  } // end void drawSplineNew()


  // ---------------------------------------- 
  void drawPointyShape() {
    beginShape();
    for (int i=0; i<cornerPoints.size(); i++) {
      vertex( cornerPointsRotated.get(i).x, cornerPointsRotated.get(i).y);
    }
    if (shapeClosed) {
      endShape(CLOSE);
    }
    else {
      endShape();
    }
  } // end void drawPointyShape()


  // ---------------------------------------- 
  void rotatePointAroundPoint(PVector thePoint, PVector theCenterToRotateAround, float theAngle) {
    thePoint.sub( theCenterToRotateAround );
    thePoint.rotate( radians(theAngle) );
    thePoint.add( theCenterToRotateAround );
  }
  // ---------------------------------------- 
  PVector rotateCopyOfPointAroundPoint(PVector thePoint, PVector theCenterToRotateAround, float theAngle) {
    PVector pRotated = thePoint.get(); // make a copy !!!
    rotatePointAroundPoint(pRotated, theCenterToRotateAround, theAngle);
    return pRotated;
  } // end PVector rotateCopyOfPointAroundPoint()


  // ---------------------------------------- 
  PVector getNewBezierPoint(PVector p1, PVector p2, PVector p3, PVector p4) {
    float x1 = p1.x;
    float y1 = p1.y;
    float x2 = p2.x;
    float y2 = p2.y;
    float x3 = p3.x;
    float y3 = p3.y;
    float x4 = p4.x;
    float y4 = p4.y;
    // ---------------------------- determine values for Bezier curve coefficients
    float cx = 3 * (x2 - x1);
    float cy = 3 * (y2 - y1);
    float bx = 3 * (x3 - x2) - cx;
    float by = 3 * (y3 - y2) - cy;
    float ax = x4 - x1 - cx - bx;
    float  ay = y4 - y1 - cy - by;

    float t1 = float (stepCnt) / numSteps;
    float t2 =  t1 * t1;
    float t3 =  t2 * t1;

    float x = ax * t3 + bx * t2 + cx * t1 + x1;
    float y = ay * t3 + by * t2 + cy * t1 + y1;

    return new PVector(x, y);
  } // end void makeStepBezierPoints(PVector p1, PVector p2, PVector p3, PVector p4
}// end class TheShape

