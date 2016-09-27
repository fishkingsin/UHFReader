public static class Log{
  public static void e(String tag, String msg){
    println("error " +tag+ " : " + msg);
  }
  public static void v(String tag, String msg){
    println("verbose "+tag+ " : " + msg);
  }
  public static void i(String tag, String msg){
    println("info "+tag+ " : " + msg);
  }
  public static void w(String tag, String msg){
    println("warning "+tag+ " : " + msg);
  }
}