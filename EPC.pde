
public class EPC {

  private int id;
  private String epc;
  private int count;
  private int rssi;
  private long age;

  public EPC(String epc) {
    this.epc = epc;
  }

  public EPC() {
    this.epc = "Known Epc";
  }

  /**
   * @return the id
   */
  public int getId() {
    return id;
  }

  /**
   * @param id the id to set
   */
  public void setId(int id) {
    this.id = id;
  }

  /**
   * @return the epc
   */
  public String getEpc() {
    return epc;
  }

  /**
   * @param epc the epc to set
   */
  public void setEpc(String epc) {
    this.epc = epc;
  }

  /**
   * @return the count
   */
  public int getCount() {
    return count;
  }

  /**
   * @param count the count to set
   */
  public void setCount(int count) {
    this.count = count;
  }

  /**
   * @return
   */
  public int getRSSI() {
    return this.rssi;
  }

  /**
   * @param rssi
   */
  public void setRSSI(int RSSI) {
    this.rssi = RSSI;
  }

  public String getRSSIString() {
    return String.valueOf(this.rssi);
  }

  /* (non-Javadoc)
   * @see java.lang.Object#toString()
   */
  @Override
    public String toString() {
    return "EPC [id=" + id + ", epc=" + epc + ", rssi=" + rssi + ", count=" + count + ", age=" + age + "]";
  }

  public long getAge() {
    return this.age;
  }

  public void setAge(long _age) {
    this.age = _age;
  }

  public int describeContents() {
    return 0;
  }
}