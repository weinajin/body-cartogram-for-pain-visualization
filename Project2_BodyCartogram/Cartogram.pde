class Cartogram {
  Polygon[] polygons;
  float totalValue ;
  int iterations = 8;
  float[] values;
  String[] names = {
    "head pain", "neck pain", "shoulder pain", "back pain", "upperarm pain", "elbow pain", "forearm pain", "wrist pain", "hand pain", "chest pain", 
    "abdominal pain", "hip pain", "thigh pain", "knee pain", "calf pain", "heel pain", "foot pain"
  };
  color[][] palette = {
    {
      #fde0dd, #fcc5c0, #fa9fb5, #f768a1, #dd3497, #ae017e, #7a0177, #49006a
    }
    , 
    {
      #ffffcc, #ffeda0, #fed976, #feb24c, #fd8d3c, #fc4e2a, #e31a1c, #bd0026, #800026
    }
    , 
    {
      #f7fcb9, #d9f0a3, #addd8e, #78c679, #41ab5d, #238443, #006837, #004529
    }
    , 
    {
      #ece7f2, #d0d1e6, #a6bddb, #74a9cf, #3690c0, #0570b0, #045a8d, #023858
    }
    , 
    {
      #d9d9d9, #bdbdbd, #969696, #737373, #525252, #252525, #000000
    }
  };

  Cartogram(float[][] bodyData, float[] values_) {
    //for each polygon, read and store polygonValue, sum to totalValue
    totalValue = 0;
    values = values_;
    polygons = new Polygon[bodyData.length];
    for (int i = 0; i < bodyData.length; i++) {
      Polygon newPoly = new Polygon(bodyData[i], values[i], 50);
      polygons[i] = newPoly;
      totalValue += values[i];
    }
  }

  void transform() {
    for ( int iter = 0; iter < iterations; iter++) {  
      float totalArea = 0; 
      float sizeErrorSum =0;
      //sum areas into totalArea
      for (int polygon = 0; polygon< polygons.length; polygon++) {
        totalArea += polygons[polygon].area();
      }
      for (int polygon = 0; polygon< polygons.length; polygon++) {
        float value = polygons[polygon].polygonValue();
        float area = polygons[polygon].area();
        float desired = totalArea * (value/totalValue);
        float radius = sqrt(area/PI);
        float mass = sqrt(desired/PI) - radius;
        float sizeError = max(area, desired)/min(area, desired);
        polygons[polygon].setRadius(radius);
        polygons[polygon].setMass(mass);
        sizeErrorSum += sizeError;
      }
      float forceReductionFactor = 1/(1+sizeErrorSum/polygons.length);
      //for each polygon
      for (int polygonNum = 0; polygonNum< polygons.length; polygonNum++) {
        //for each vertex of polygon
        for (int vertexNum = 0; vertexNum < polygons[polygonNum].vertexCount (); vertexNum ++) {
          PVector vertex = polygons[polygonNum].getVertex(vertexNum);
          float xSum = 0; 
          float ySum = 0; //will sum of all forces from centroid to this vertex
          //for each polygon centroid
          for (int pCentroidNum = 0; pCentroidNum < polygons.length; pCentroidNum ++) {
            //find distance from centroid to coordinate
            float radiusP = polygons[pCentroidNum].getRadius();
            float massP = polygons[pCentroidNum].getMass();
            float distance = vertex.dist(polygons[pCentroidNum].centroid());
            float Fij = (distance > radiusP )? massP*(radiusP / distance): massP*(sq(distance)/sq(radiusP) )* ( 4 - 3 * (distance/ radiusP));
            //using Fij and angle, calculate vector sum 
            float angle = PVector.angleBetween(polygons[pCentroidNum].centroid(), vertex );
            float dx = vertex.x - polygons[pCentroidNum].centroid().x;
            float dy = vertex.y - polygons[pCentroidNum].centroid().y;
            xSum += Fij * cosArctan(dy, dx);
            ySum += Fij * sinArctan(dy, dx);
          }
          xSum = xSum * forceReductionFactor + vertex.x;
          ySum = ySum * forceReductionFactor + vertex.y;
          polygons[polygonNum].setVertex(vertexNum, xSum, ySum);
        }
      }
    }
  }

  float  cosArctan(float dx, float dy) {
    float div = dx/dy;
    return (dy>0)? (1/sqrt(1+(div*div))): (-1/sqrt(1+(div*div)));
  }

  float  sinArctan(float dx, float dy) {
    float div = dx/dy;
    return (dy>0)?(div/sqrt(1+(div*div))):(-div/sqrt(1+(div*div)));
  }

  //draw the polygon
  void display(boolean strokeSwitch, int colorHue) {
    float[] valueCopy = values.clone();
    color newColor = color(255, 0, 0);
    Arrays.sort(valueCopy);
    pushMatrix();
    noStroke();
    //colorMode(HSB,360,100,100);
    for (int i = 0; i < polygons.length; i++) {
      Polygon thisP = polygons[i];      
      pushMatrix();
      for (int j = 0; j < valueCopy.length; j++) {
        if ( thisP.polygonValue() == valueCopy[j] ) {
          int dense = (int)map(j, 0, valueCopy.length, 0, palette[colorHue].length);
          newColor= palette[colorHue][dense];
          break;
        }
      }
      // draw stroke color
      if (strokeSwitch) {
        thisP.setStroke(color(0, 0, 40));
        thisP.setFill(newColor);
      } else {
        thisP.setColor(newColor);
      }
      shape(polygons[i].getPShape());
      popMatrix();
    }
    popMatrix();
  }

  void textShow(float x, float y) {
    pushMatrix();
    //distance detector of mouse and centroid
    for (int i = 0; i < polygons.length; i++) {
      Polygon thisP = polygons[i];   
      //  translate(250, 20);  scale(-1.0, 1.0);
      if (dist(x, y, thisP.centroid().x * (-1) +250, thisP.centroid().y +20) < 20) {
        float product = thisP.polygonValue()/totalValue * 100;
        String value;
        if (product >0) {
          if (product > 1) {
            value = str(int(product));
          } else {
            value = "0." +str(int(product*100));   // ? nf(product, 2, 0) : nf(product, 0, 2);
          }
          String showValue = names[i] + ": " +value + " %";
          fill(255);
          noStroke();
          rect(x+6, y-18, 100, 20, 10);
          fill(0);
          text(showValue, x+10, y-5);
        }
      }
    }
    popMatrix();
  }

  void setValues(float[] newValues) {
    totalValue = 0;
    values = newValues;
    polygons = new Polygon[bodyData.length];
    for (int i = 0; i < bodyData.length; i++) {
      Polygon newPoly = new Polygon(bodyData[i], values[i], 50);
      polygons[i] = newPoly;
      totalValue += values[i];
    }
    transform();
  }

  float getTotalValue() {
    return totalValue;
  }
  Polygon[] getPolygons() {
    return polygons;
  }
}

