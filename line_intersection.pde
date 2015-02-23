static boolean getLineLineIntersection(Line2D.Double l1,
                                       Line2D.Double l2,
                                       Point2D.Double intersection)
{
    //if (!l1.intersectsLine(l2))
    //    return false;
    
    double  x1 = l1.getX1(), y1 = l1.getY1(),
            x2 = l1.getX2(), y2 = l1.getY2(),
            x3 = l2.getX1(), y3 = l2.getY1(),
            x4 = l2.getX2(), y4 = l2.getY2();
    
    intersection.x = det(det(x1, y1, x2, y2), x1 - x2,
                         det(x3, y3, x4, y4), x3 - x4)/
                     det(x1 - x2, y1 - y2, x3 - x4, y3 - y4);
    intersection.y = det(det(x1, y1, x2, y2), y1 - y2,
                         det(x3, y3, x4, y4), y3 - y4)/
                     det(x1 - x2, y1 - y2, x3 - x4, y3 - y4);

    return true;
}

static double det(double a, double b, double c, double d)
{
    return a * d - b * c;
}

double line_length(Line2D.Double l){
  Point2D.Double p1 = (Point2D.Double)l.getP1();
  Point2D.Double p2 = (Point2D.Double)l.getP2();
  
  double x = (p1.getX() - p2.getX());
  double y = (p1.getY() - p2.getY());
  
  return (double)sqrt((float)(x*x+y*y));
}
