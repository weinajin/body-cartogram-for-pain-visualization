class Polygon extends PolygonAbst {
  float polygonArea;
  PShape p;
  float radius;
  float mass;

  Polygon(float[] bodyPart, float polygonValue_, color initC) {
    super(polygonValue_, initC);
    //polygon from point value
    p = createShape();
    p.beginShape();
    p.stroke(c);
    p.fill(c);
    for (int i=0; i<bodyPart.length; i+=2) {
      p.vertex(bodyPart[i], bodyPart[i+1]);
    }
    p.endShape(CLOSE);
  }

  //constructor overloading, polygon from svg file
  Polygon(String svgFile, float polygonValue_, color initC ) {
    super(polygonValue_, initC);
    p = loadShape(svgFile);   // *.svg
  }

  int vertexCount() {
    return p.getVertexCount();
  }

  PVector getVertex(int i) {
    return p.getVertex(i);
  }

  void setVertex(int i, float vx, float vy) {
    p.setVertex(i, vx, vy);
  }

  PShape getPShape() {
    return p;
  }
  void setRadius(float r) {
    radius = r;
  }
  float getRadius() {
    return radius;
  }

  void setMass(float m) {
    mass = m;
  }
  float getMass() {
    return mass;
  }

  PVector centroid() {
    float sumX = 0;
    float sumY = 0;
    for (int i=0; i<p.getVertexCount (); i++) {
      sumX += p.getVertex(i).x;
      sumY += p.getVertex(i).y;
    }
    PVector centroid = new PVector(sumX/p.getVertexCount(), sumY/p.getVertexCount());
    return centroid;
  }

  float area() {
    float area=0;
    for (int i=0; i<p.getVertexCount (); i++) { //x1y2 - y1x2
      area += p.getVertex(i).x * p.getVertex((i+1)% p.getVertexCount()).y;
      area -= p.getVertex(i).y * p.getVertex((i+1)% p.getVertexCount()).x;
    }
    return abs(area)/2;
  }

  void setFill(color newC) {
    p.setFill(newC);
  }
  void setStroke(color newC) {
    p.setStrokeWeight(0.5);
    p.setStroke(newC);
  }
  void setColor(color newC) {
    p.setStrokeWeight(0.5);
    p.setFill(newC);
    p.setStroke(newC);
  }
}

abstract class PolygonAbst {
  color c;
  float polygonValue;

  PolygonAbst(float value) {
    c = color( 0, 0, 40);  //grey
    polygonValue = value;
  }

  PolygonAbst(float value, color initC) {
    c = initC;
    polygonValue = value;
  }

  float polygonValue() {
    return polygonValue;
  }

  color getColor() {
    return c;
  }

  void setColor(color newC) {
    c = newC;
  }
}

