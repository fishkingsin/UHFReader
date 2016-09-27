class NewSendCommendManager implements CommendManager {
  final static String TAG = "NewSendCommendManager";
  private final byte HEAD = -69;
  private final byte END = 126;
  public static final byte RESPONSE_OK = 0;
  public static final byte ERROR_CODE_ACCESS_FAIL = 22;
  public static final byte ERROR_CODE_NO_CARD = 9;
  public static final byte ERROR_CODE_READ_SA_OR_LEN_ERROR = -93;
  public static final byte ERROR_CODE_WRITE_SA_OR_LEN_ERROR = -77;
  public static final int SENSITIVE_HIHG = 3;
  public static final int SENSITIVE_MIDDLE = 2;
  public static final int SENSITIVE_LOW = 1;
  public static final int SENSITIVE_VERY_LOW = 0;
  Serial myPort;
  private byte[] selectEPC = null;
  NewSendCommendManager(Serial port) {
    myPort = port;
  }
  public void sendCMD(byte[] cmd) {
    try {
      myPort.write(cmd);
    } 
    catch (Exception var3) {
      var3.printStackTrace();
    }
  }

  public boolean setBaudrate(int baudrate) {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 17, (byte) 0, (byte) 2, (byte) 4, (byte) -128, (byte) -105, (byte) 126};
    cmd[5] = (byte) (baudrate / 100 >> 8);
    cmd[6] = (byte) (baudrate / 100 & 255);
    cmd[cmd.length - 2] = this.checkSum(cmd);
    this.sendCMD(cmd);
    return true;
  }

  public byte[] getFirmware() {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 3, (byte) 0, (byte) 1, (byte) 1, (byte) 4, (byte) 126};
    cmd[6] = this.checkSum(cmd);
    byte[] version = null;
    this.sendCMD(cmd);
    byte[] response = this.read();
    if (response != null) {
      byte[] resolve = this.handlerResponse(response);
      if (resolve != null && resolve.length > 1) {
        version = new byte[resolve.length - 1];
        System.arraycopy(resolve, 1, version, 0, resolve.length - 1);
      }
    }

    return version;
  }

  public byte[] getHardwareVersion() {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 3, (byte) 0, (byte) 1, (byte) 0, (byte) 5, (byte) 126};
    cmd[6] = this.checkSum(cmd);
    byte[] version = null;
    this.sendCMD(cmd);
    byte[] response = this.read();
    if (response != null) {
      byte[] resolve = this.handlerResponse(response);
      if (resolve != null && resolve.length > 1) {
        version = new byte[resolve.length - 1];
        System.arraycopy(resolve, 1, version, 0, resolve.length - 1);
      }
    }

    return version;
  }

  public byte[] getManufacturer() {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 3, (byte) 0, (byte) 1, (byte) 2, (byte) 6, (byte) 126};
    cmd[6] = this.checkSum(cmd);
    byte[] manufacturer = null;
    this.sendCMD(cmd);
    byte[] response = this.read();
    if (response != null) {
      byte[] resolve = this.handlerResponse(response);
      if (resolve != null && resolve.length > 1) {
        manufacturer = new byte[resolve.length - 1];
        System.arraycopy(resolve, 1, manufacturer, 0, resolve.length - 1);
      }
    }

    return manufacturer;
  }

  public byte[] read() {
    Object responseData = null;
    byte[] response = null;
    int available = 0;
    int index = 0;
    int headIndex = 0;

    try {
      while (index < 10) {
        Thread.sleep(50L);
        available = myPort.available();
        if (available > 7) {
          break;
        }

        ++index;
      }

      Thread.sleep(50L);
      if (available > 0) {
        available = myPort.available();
        byte[] var8 = new byte[available];
        myPort.readBytes(var8);

        for (int e1 = 0; e1 < available; ++e1) {
          if (var8[e1] == -69) {
            headIndex = e1;
            break;
          }
        }

        response = new byte[available - headIndex];
        System.arraycopy(var8, headIndex, response, 0, response.length);
        //                //Log.i("read", Tools.Bytes2HexString(var8, var8.length));
      }
    } 
    catch (Exception var7) {
      var7.printStackTrace();
    }

    return response;
  }

  public boolean setOutputPower(int power) {
    Object recv = null;
    Object content = null;
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) -74, (byte) 0, (byte) 2, (byte) (power >> 8), (byte) (power & 255), (byte) 0, (byte) 0};
    cmd[7] = this.checkSum(cmd);
    cmd[8] = 126;
    this.sendCMD(cmd);
    byte[] recv1 = this.read();
    if (recv1 != null) {
      byte[] content1 = this.handlerResponse(recv1);
      if (content1 != null) {
        return true;
      }
    }

    return false;
  }

  public boolean setSensitivity(int value) {
    boolean mixer = true;
    boolean if_g = true;
    boolean trd = true;
    byte mixer1;
    byte if_g1;
    short trd1;
    switch (value) {
    case 16:
      mixer1 = 1;
      if_g1 = 1;
      trd1 = 432;
      break;
    case 17:
      mixer1 = 1;
      if_g1 = 3;
      trd1 = 432;
      break;
    case 18:
      mixer1 = 2;
      if_g1 = 4;
      trd1 = 432;
      break;
    case 19:
      mixer = true;
      if_g = true;
      trd = true;
    case 20:
      mixer = true;
      if_g = true;
      trd = true;
    case 21:
      mixer1 = 2;
      if_g1 = 6;
      trd1 = 560;
      break;
    case 22:
      mixer1 = 3;
      if_g1 = 6;
      trd1 = 624;
      break;
    case 23:
      mixer1 = 4;
      if_g1 = 6;
      trd1 = 624;
      break;
    default:
      mixer1 = 6;
      if_g1 = 7;
      trd1 = 624;
    }

    return this.setModemParam(mixer1, if_g1, trd1);
  }

  public boolean setModemParam(int mixer_g, int if_g, int trd) {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) -16, (byte) 0, (byte) 4, (byte) 3, (byte) 6, (byte) 1, (byte) -80, (byte) -82, (byte) 126};
    Object recv = null;
    Object content = null;
    cmd[5] = (byte) mixer_g;
    cmd[6] = (byte) if_g;
    cmd[7] = (byte) (trd / 256);
    cmd[8] = (byte) (trd % 256);
    cmd[9] = this.checkSum(cmd);
    Log.i("setModemParam", "cmd: " + Tools.Bytes2HexString(cmd, cmd.length));
    this.sendCMD(cmd);
    byte[] recv1 = this.read();
    if (recv1 != null) {
      byte [] ret = handlerResponse(recv1);
      Log.i("result", "ret: " + Tools.Bytes2HexString(ret, ret.length));
      byte[] content1 = this.handlerResponse(recv1);
      if (content1 != null) {
        return true;
      }
    }
    
    return false;
  }

  public byte[] getModemParam() {
    Object recv = null;
    byte[] content = null;
    byte[] modemPara = new byte[4];
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) -15, (byte) 0, (byte) 0, (byte) -15, (byte) 126};
    this.sendCMD(cmd);
    byte[] recv1 = this.read();
    if (recv1 != null) {
      content = this.handlerResponse(recv1);
    }

    if (content != null) {
      System.arraycopy(content, 1, modemPara, 0, 4);
    }

    return modemPara;
  }

  public List<byte[]> inventoryMulti() {
    ArrayList list = new ArrayList();
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 39, (byte) 0, (byte) 3, (byte) 34, (byte) 39, (byte) 16, (byte) -125, (byte) 126};
    this.sendCMD(cmd);
    byte[] response = this.read();
    if (response != null) {
      int responseLength = response.length;
      int start = 0;
      if (responseLength >= 12) {
        while (responseLength > 11) {
          int paraLen = response[start + 4] & 255;
          int singleCardLen = paraLen + 7;
          if (singleCardLen > responseLength) {
            break;
          }

          byte[] sigleCard = new byte[singleCardLen];
          System.arraycopy(response, start, sigleCard, 0, singleCardLen);
          byte[] resolve = this.handlerResponse(sigleCard);
          if (resolve != null) {
            if (paraLen > 5) {
              byte[] epcBytes = new byte[paraLen - 5];
              System.arraycopy(resolve, 4, epcBytes, 0, paraLen - 5);
              list.add(epcBytes);
              ////Log.i("got EPC", Tools.Bytes2HexString(epcBytes, epcBytes.length));
            } else {
              Object epcBytes1 = null;
              //                            list.add(epcBytes1);
              //Log.e("got EPC", "empty EPC, response data: " + Tools.Bytes2HexString(resolve, resolve.length));
            }
          }

          start += singleCardLen;
          responseLength -= singleCardLen;
        }
      } else {
        this.handlerResponse(response);
      }
    }

    return list;
  }

  public void stopInventoryMulti() {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 40, (byte) 0, (byte) 0, (byte) 40, (byte) 126};
    this.sendCMD(cmd);
    byte[] recv = this.read();
  }


  public List<EPC> EPCRealTime() {
    this.unSelect();
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 34, (byte) 0, (byte) 0, (byte) 34, (byte) 126};
    this.sendCMD(cmd);
    ArrayList list = new ArrayList();
    byte[] response = this.read();
    if (response != null) {
      int responseLength = response.length;
      int start = 0;
      if (responseLength >= 12) {
        while (responseLength > 11) {
          int paraLen = response[start + 4] & 255;
          int singleCardLen = paraLen + 7;
          if (singleCardLen > responseLength) {
            break;
          }

          byte[] sigleCard = new byte[singleCardLen];
          System.arraycopy(response, start, sigleCard, 0, singleCardLen);
          byte[] resolve = this.handlerResponse(sigleCard);
          ////Log.i(TAG, "got Data : " + Tools.Bytes2HexString(resolve, resolve.length));
          if (resolve != null) {
            if (paraLen > 5) {
              byte[] epcBytes = new byte[paraLen - 5];
              System.arraycopy(resolve, 4, epcBytes, 0, paraLen - 5);
              EPC epc = new EPC();
              String spcString = Tools.Bytes2HexString(epcBytes, epcBytes.length);
              epc.setEpc(spcString);
              epc.setRSSI((int) (resolve[1]));
              list.add(epc);
              ////Log.i(TAG, "got EPC " + spcString);
            } else {
              EPC epc = new EPC();
              epc.setEpc("");
              list.add(epc);
              ////Log.i(TAG, "got EPC " + "empty EPC, response data: " + Tools.Bytes2HexString(resolve, resolve.length));
            }
          }

          start += singleCardLen;
          responseLength -= singleCardLen;
        }
      } else {
        this.handlerResponse(response);
      }
    }

    return list;
  }

  public List<byte[]> inventoryRealTime() {
    this.unSelect();
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 34, (byte) 0, (byte) 0, (byte) 34, (byte) 126};
    this.sendCMD(cmd);
    ArrayList list = new ArrayList();
    byte[] response = this.read();
    if (response != null) {
      int responseLength = response.length;
      int start = 0;
      if (responseLength >= 12) {
        while (responseLength > 11) {
          int paraLen = response[start + 4] & 255;
          int singleCardLen = paraLen + 7;
          if (singleCardLen > responseLength) {
            break;
          }

          byte[] sigleCard = new byte[singleCardLen];
          System.arraycopy(response, start, sigleCard, 0, singleCardLen);
          byte[] resolve = this.handlerResponse(sigleCard);
          if (resolve != null) {
            if (paraLen > 5) {
              byte[] epcBytes = new byte[paraLen - 5];
              System.arraycopy(resolve, 4, epcBytes, 0, paraLen - 5);
              list.add(epcBytes);
              ////Log.i("got EPC", Tools.Bytes2HexString(epcBytes, epcBytes.length));
            } else {
              Object epcBytes1 = null;
              list.add(epcBytes1);
              //Log.e("got EPC", "empty EPC, response data: " + Tools.Bytes2HexString(resolve, resolve.length));
            }
          }

          start += singleCardLen;
          responseLength -= singleCardLen;
        }
      } else {
        this.handlerResponse(response);
      }
    }

    return list;
  }

  public void setSelectMode(byte mode) {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 18, (byte) 0, (byte) 1, (byte) 1, (byte) 19, (byte) 126};
    cmd[5] = mode;
    this.sendCMD(cmd);
    byte[] response = this.read();
  }

  public void selectEpc(byte[] epc) {
    this.selectEPC = epc;
    this.selectEpc();
  }

  public boolean unSelect() {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 18, (byte) 0, (byte) 1, (byte) 1, (byte) 20, (byte) 126};
    this.sendCMD(cmd);
    byte[] response = this.read();
    return true;
  }

  private void selectEpc() {
    byte[] cmd = new byte[14 + this.selectEPC.length];
    cmd[0] = -69;
    cmd[1] = 0;
    cmd[2] = 12;
    cmd[3] = 0;
    cmd[4] = (byte) (7 + this.selectEPC.length);
    cmd[5] = 1;
    cmd[6] = 0;
    cmd[7] = 0;
    cmd[8] = 0;
    cmd[9] = 32;
    cmd[10] = (byte) (this.selectEPC.length * 8);
    cmd[11] = 0;
    if (this.selectEPC != null) {
      //Log.v("", "select epc");
      System.arraycopy(this.selectEPC, 0, cmd, 12, this.selectEPC.length);
      cmd[cmd.length - 2] = this.checkSum(cmd);
      cmd[cmd.length - 1] = 126;
      this.sendCMD(cmd);
      byte[] var2 = this.read();
    }
  }

  public void setSelectPara(byte target, byte action, byte memBank, int pointer, byte maskLen, boolean truncated, byte[] mask) {
    int cmdLen = 14 + maskLen;
    int parameterLen = 7 + maskLen;
    byte[] cmd = new byte[cmdLen];
    cmd[0] = -69;
    cmd[1] = 0;
    cmd[2] = 12;
    cmd[3] = 0;
    cmd[4] = (byte) parameterLen;
    cmd[5] = (byte) (target << 5 | action << 2 | memBank);
    cmd[6] = (byte) (pointer >> 24);
    cmd[7] = (byte) (pointer >> 16);
    cmd[8] = (byte) (pointer >> 8);
    cmd[9] = (byte) (pointer >> 0);
    cmd[10] = maskLen;
    cmd[11] = (byte) (truncated ? 1 : 0);
    ////Log.i("select para: ", cmd[5] + " " + pointer + " " + maskLen + " " + Tools.Bytes2HexString(mask, maskLen));
    System.arraycopy(mask, 0, cmd, 12, maskLen);
    cmd[cmd.length - 2] = this.checkSum(cmd);
    this.sendCMD(cmd);
    byte[] arrayOfByte1 = this.read();
  }

  public byte[] readFrom6C(int memBank, int startAddr, int length, byte[] accessPassword) {
    this.selectEpc();
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 57, (byte) 0, (byte) 9, (byte) 0, (byte) 0, (byte) 0, (byte) 0, (byte) 3, (byte) 0, (byte) 0, (byte) 0, (byte) 8, (byte) 77, (byte) 126};
    byte[] data = null;
    if (accessPassword != null && accessPassword.length == 4) {
      System.arraycopy(accessPassword, 0, cmd, 5, 4);
      cmd[9] = (byte) memBank;
      int response;
      int resolve;
      if (startAddr <= 255) {
        cmd[10] = 0;
        cmd[11] = (byte) startAddr;
      } else {
        response = startAddr / 256;
        resolve = startAddr % 256;
        cmd[10] = (byte) response;
        cmd[11] = (byte) resolve;
      }

      if (length <= 255) {
        cmd[12] = 0;
        cmd[13] = (byte) length;
      } else {
        response = length / 256;
        resolve = length % 256;
        cmd[12] = (byte) response;
        cmd[13] = (byte) resolve;
      }

      cmd[14] = this.checkSum(cmd);
      this.sendCMD(cmd);
      byte[] response1 = this.read();
      if (response1 != null) {
        ////Log.i("readFrom6c response", Tools.Bytes2HexString(response1, response1.length));
        byte[] resolve1 = this.handlerResponse(response1);
        if (resolve1 != null) {
          ////Log.i("readFrom6c resolve", Tools.Bytes2HexString(resolve1, resolve1.length));
          if (resolve1[0] == 57) {
            int lengData = resolve1.length - resolve1[1] - 2;
            data = new byte[lengData];
            System.arraycopy(resolve1, resolve1[1] + 2, data, 0, lengData);
          } else {
            data = new byte[]{resolve1[1]};
          }
        }
      }

      return data;
    } else {
      return null;
    }
  }

  public boolean writeTo6C(byte[] password, int memBank, int startAddr, int dataLen, byte[] data) {
    this.selectEpc();
    if (password != null && password.length == 4) {
      boolean writeFlag = false;
      int cmdLen = 16 + data.length;
      int parameterLen = 9 + data.length;
      byte[] cmd = new byte[cmdLen];
      cmd[0] = -69;
      cmd[1] = 0;
      cmd[2] = 73;
      int response;
      int resolve;
      if (parameterLen < 256) {
        cmd[3] = 0;
        cmd[4] = (byte) parameterLen;
      } else {
        response = parameterLen / 256;
        resolve = parameterLen % 256;
        cmd[3] = (byte) response;
        cmd[4] = (byte) resolve;
      }

      System.arraycopy(password, 0, cmd, 5, 4);
      cmd[9] = (byte) memBank;
      if (startAddr < 256) {
        cmd[10] = 0;
        cmd[11] = (byte) startAddr;
      } else {
        response = startAddr / 256;
        resolve = startAddr % 256;
        cmd[10] = (byte) response;
        cmd[11] = (byte) resolve;
      }

      if (dataLen < 256) {
        cmd[12] = 0;
        cmd[13] = (byte) dataLen;
      } else {
        response = dataLen / 256;
        resolve = dataLen % 256;
        cmd[12] = (byte) response;
        cmd[13] = (byte) resolve;
      }

      System.arraycopy(data, 0, cmd, 14, data.length);
      cmd[cmdLen - 2] = this.checkSum(cmd);
      cmd[cmdLen - 1] = 126;
      this.sendCMD(cmd);

      try {
        Thread.sleep(50L);
      } 
      catch (InterruptedException var12) {
        var12.printStackTrace();
      }

      byte[] response1 = this.read();
      if (response1 != null) {
        byte[] resolve1 = this.handlerResponse(response1);
        if (resolve1 != null && resolve1[0] == 73 && resolve1[resolve1.length - 1] == 0) {
          writeFlag = true;
        }
      }

      return writeFlag;
    } else {
      return false;
    }
  }

  public boolean lock6CwithPayload(byte[] password, int payload) {
    this.selectEpc();
    if (password != null && password.length == 4) {
      boolean lockFlag = false;
      byte cmdLen = 14;
      byte[] cmd = new byte[cmdLen];
      cmd[0] = -69;
      cmd[1] = 0;
      cmd[2] = -126;
      cmd[3] = 0;
      cmd[4] = 7;
      System.arraycopy(password, 0, cmd, 5, 4);
      cmd[9] = (byte) (payload >> 16 & 255);
      cmd[10] = (byte) (payload >> 8 & 255);
      cmd[11] = (byte) (payload & 255);
      cmd[cmdLen - 2] = this.checkSum(cmd);
      cmd[cmdLen - 1] = 126;
      this.sendCMD(cmd);

      try {
        Thread.sleep(50L);
      } 
      catch (InterruptedException var8) {
        var8.printStackTrace();
      }

      byte[] response = this.read();
      if (response != null) {
        byte[] resolve = this.handlerResponse(response);
        if (resolve != null && resolve[0] == -126 && resolve[resolve.length - 1] == 0) {
          lockFlag = true;
        }
      }

      return lockFlag;
    } else {
      return false;
    }
  }

  public int genLockPayload(int memSpace, int lockType) {
    boolean payload = false;
    byte byte0 = 0;
    byte byte1 = 0;
    byte byte2 = 0;
    switch (memSpace) {
    case 0:
      if (lockType == 0) {
        byte0 = (byte) (byte0 | 8);
        byte1 = (byte) (byte1 | 0);
      } else if (lockType == 1) {
        byte0 = (byte) (byte0 | 8);
        byte1 = (byte) (byte1 | 2);
      } else if (lockType == 2) {
        byte0 = (byte) (byte0 | 12);
        byte1 = (byte) (byte1 | 1);
      } else if (lockType == 3) {
        byte0 = (byte) (byte0 | 12);
        byte1 = (byte) (byte1 | 3);
      }
      break;
    case 1:
      if (lockType == 0) {
        byte0 = (byte) (byte0 | 2);
        byte2 = (byte) (byte2 | 0);
      } else if (lockType == 1) {
        byte0 = (byte) (byte0 | 2);
        byte2 = (byte) (byte2 | 128);
      } else if (lockType == 2) {
        byte0 = (byte) (byte0 | 3);
        byte2 = (byte) (byte2 | 64);
      } else if (lockType == 3) {
        byte0 = (byte) (byte0 | 3);
        byte2 = (byte) (byte2 | 192);
      }
      break;
    case 2:
      if (lockType == 0) {
        byte1 = (byte) (byte1 | 128);
        byte2 = (byte) (byte2 | 0);
      } else if (lockType == 1) {
        byte1 = (byte) (byte1 | 128);
        byte2 = (byte) (byte2 | 32);
      } else if (lockType == 2) {
        byte1 = (byte) (byte1 | 192);
        byte2 = (byte) (byte2 | 16);
      } else if (lockType == 3) {
        byte1 = (byte) (byte1 | 192);
        byte2 = (byte) (byte2 | 48);
      }
      break;
    case 3:
      if (lockType == 0) {
        byte1 = (byte) (byte1 | 32);
        byte2 = (byte) (byte2 | 0);
      } else if (lockType == 1) {
        byte1 = (byte) (byte1 | 32);
        byte2 = (byte) (byte2 | 8);
      } else if (lockType == 2) {
        byte1 = (byte) (byte1 | 48);
        byte2 = (byte) (byte2 | 4);
      } else if (lockType == 3) {
        byte1 = (byte) (byte1 | 48);
        byte2 = (byte) (byte2 | 12);
      }
      break;
    case 4:
      if (lockType == 0) {
        byte1 = (byte) (byte1 | 8);
        byte2 = (byte) (byte2 | 0);
      } else if (lockType == 1) {
        byte1 = (byte) (byte1 | 8);
        byte2 = (byte) (byte2 | 2);
      } else if (lockType == 2) {
        byte1 = (byte) (byte1 | 12);
        byte2 = (byte) (byte2 | 1);
      } else if (lockType == 3) {
        byte1 = (byte) (byte1 | 12);
        byte2 = (byte) (byte2 | 3);
      }
    }

    int payload1 = byte0 << 16 | byte1 << 8 | byte2;
    return payload1;
  }

  public boolean lock6C(byte[] password, int memSpace, int lockType) {
    int payload = this.genLockPayload(memSpace, lockType);
    return this.lock6CwithPayload(password, payload);
  }

  public boolean kill6C(byte[] password) {
    return this.kill6C(password, 0);
  }

  public boolean kill6C(byte[] password, int rfu) {
    this.selectEpc();
    if (password != null && password.length == 4) {
      boolean killFlag = false;
      int cmdLen = 11;
      if (rfu != 0) {
        ++cmdLen;
      }

      byte[] cmd = new byte[cmdLen];
      cmd[0] = -69;
      cmd[1] = 0;
      cmd[2] = 101;
      cmd[3] = 0;
      cmd[4] = 4;
      if (rfu != 0) {
        ++cmd[4];
        cmd[9] = (byte) rfu;
      }

      System.arraycopy(password, 0, cmd, 5, 4);
      cmd[cmdLen - 2] = this.checkSum(cmd);
      cmd[cmdLen - 1] = 126;
      this.sendCMD(cmd);

      try {
        Thread.sleep(50L);
      } 
      catch (InterruptedException var8) {
        var8.printStackTrace();
      }

      byte[] response = this.read();
      if (response != null) {
        byte[] resolve = this.handlerResponse(response);
        if (resolve != null && resolve[0] == 101 && resolve[resolve.length - 1] == 0) {
          killFlag = true;
        }
      }

      return killFlag;
    } else {
      return false;
    }
  }

  public void close() {
    try {
      myPort.stop();
      myPort.stop();
    }
    catch (Exception var2) {
      var2.printStackTrace();
    }
  }

  public byte checkSum(byte[] data) {
    byte crc = 0;

    for (int i = 1; i < data.length - 2; ++i) {
      crc += data[i];
    }

    return crc;
  }

  private byte[] handlerResponse(byte[] response) {
    byte[] data = null;
    boolean crc = false;
    int responseLength = response.length;
    if (response.length == 0) {
      Log.e("handlerResponse", "response null");
      return data;
    }
    if (response[0] != -69) {
      Log.e("handlerResponse", "head error");
      return data;
    } else if (response[responseLength - 1] != 126) {
      Log.e("handlerResponse", "end error");
      return data;
    } else if (responseLength < 7) {
      return data;
    } else {
      int lengthHigh = response[3] & 255;
      int lengthLow = response[4] & 255;
      int dataLength = lengthHigh * 256 + lengthLow;
      byte crc1 = this.checkSum(response);
      if (crc1 != response[responseLength - 2]) {
        Log.e("handlerResponse", "crc error");
        return data;
      } else {
        if (dataLength != 0 && responseLength == dataLength + 7) {
          Log.v("handlerResponse", "response right");
          data = new byte[dataLength + 1];
          data[0] = response[2];
          System.arraycopy(response, 5, data, 1, dataLength);
        }

        return data;
      }
    }
  }

  public int setFrequency(int startFrequency, int freqSpace, int freqQuality) {
    int frequency = 1;
    if (startFrequency > 840125 && startFrequency < 844875) {
      frequency = (startFrequency - 840125) / 250;
    } else if (startFrequency > 920125 && startFrequency < 924875) {
      frequency = (startFrequency - 920125) / 250;
    } else if (startFrequency > 865100 && startFrequency < 867900) {
      frequency = (startFrequency - 865100) / 200;
    } else if (startFrequency > 902250 && startFrequency < 927750) {
      frequency = (startFrequency - 902250) / 500;
    }

    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) -85, (byte) 0, (byte) 1, (byte) 4, (byte) -80, (byte) 126};
    cmd[5] = (byte) frequency;
    cmd[6] = this.checkSum(cmd);
    this.sendCMD(cmd);
    byte[] recv = this.read();
    if (recv != null) {
      Log.e("frequency", Tools.Bytes2HexString(recv, recv.length));
    }

    return 0;
  }

  public boolean setFrequency(int index) {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) -85, (byte) 0, (byte) 1, (byte) index, (byte) 5, (byte) 126};
    cmd[6] = this.checkSum(cmd);
    this.sendCMD(cmd);
    byte[] recv = this.read();
    if (recv != null) {
      ////Log.i("setFrequency ", Tools.Bytes2HexString(recv, recv.length));
      this.handlerResponse(recv);
    }

    return true;
  }

  public boolean setWorkArea(int area) {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 7, (byte) 0, (byte) 1, (byte) 1, (byte) 9, (byte) 126};
    cmd[5] = (byte) area;
    cmd[6] = this.checkSum(cmd);
    this.sendCMD(cmd);
    byte[] recv = this.read();
    if (recv != null) {
      ////Log.i("setWorkArea", Tools.Bytes2HexString(recv, recv.length));
      this.handlerResponse(recv);
    }

    return true;
  }

  public int getWorkArea() {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) 8, (byte) 0, (byte) 0, (byte) 8, (byte) 126};
    this.sendCMD(cmd);
    byte[] recv = this.read();
    if (recv != null) {
      ////Log.i("getWorkArea", Tools.Bytes2HexString(recv, recv.length));
      byte[] area = this.handlerResponse(recv);
      if (area[0] == 8) {
        return area[1];
      }
    }

    return -1;
  }

  public int getFrequency() {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) -86, (byte) 0, (byte) 0, (byte) -86, (byte) 126};
    this.sendCMD(cmd);
    byte[] recv = this.read();
    if (recv != null) {
      //Log.i("getFrequency", Tools.Bytes2HexString(recv, recv.length));
      this.handlerResponse(recv);
    }

    return 0;
  }

  public boolean setFHSS(boolean on) {
    byte[] cmd = new byte[]{(byte) -69, (byte) 0, (byte) -83, (byte) 0, (byte) 1, (byte) (on ? 1 : 0), (byte) 5, (byte) 126};
    cmd[6] = this.checkSum(cmd);
    this.sendCMD(cmd);
    //Log.i("setFhss: ", on ? "on" : "off");
    byte[] recv = this.read();
    if (recv != null) {
      this.handlerResponse(recv);
      return true;
    } else {
      return false;
    }
  }
  /**
   * Header | Type | Command | PL(MSB) | PL(LSB) | Mixer_G | IF_G | Thrd(MSB) | Thrd(LSB) | Checksum | End
   * BB     | 00   | F0      | 00      | 04      | 03      | 06   | 01        | B0        | AE       | 7E
   *
   * Mixer Gain
   * Type | Mixer_G(dB)
   * 0x00 | 0
   * 0x01 | 3
   * 0x02 | 6
   * 0x03 | 9
   * 0x04 | 12
   * 0x05 | 15
   * 0x06 | 16
   *
   * IF AMP
   *
   * Type | IF_G(dB)
   * 0x00 | 12
   * 0x01 | 18
   * 0x02 | 21
   * 0x03 | 24
   * 0x04 | 27
   * 0x05 | 30
   * 0x06 | 36
   * 0x07 | 40
   */
  public int setModemParaFrame(int mixerGain, int IFAmpGain, int signalThreshold) {


    byte TYPE = 0x00;
    byte COMMAND = (byte) 0xF0;
    byte PL_MSB = 0x00;
    byte PL_LSB = 0x04;
    byte Mixer_G = toMixerGain(mixerGain);
    byte IF_G = toIFAmpGain(IFAmpGain);
    byte[] Threshold = toThreshold(signalThreshold);
    byte Thrd_MSB = 0x01;
    byte Thrd_LSB = (byte) 0xB0;
    byte CHECK_SUM = (byte) 0xAE;
    byte[] cmd = new byte[]{HEAD, TYPE, COMMAND, PL_MSB, PL_LSB, Mixer_G, IF_G, IF_G, Thrd_MSB, Thrd_LSB, CHECK_SUM, END};
    Log.e("setModemParaFrame", "cmd :"+Tools.Bytes2HexString(cmd, cmd.length));
    this.sendCMD(cmd);
    byte[] recv = this.read();
    if (recv != null) {
      Log.e("setModemParaFrame", Tools.Bytes2HexString(recv, recv.length));
    }

    return 0;
  }

  private byte[] toThreshold(int signalThreshold) {
    switch(signalThreshold) {
    case 0:
      return new byte[]{0x00, (byte) 0xA0};
    case 1:
      return new byte[]{0x01, (byte) 0xB0};
    case 2:
      return new byte[]{0x01, (byte) 0x20};
    case 3:
      return new byte[]{0x02, (byte) 0x80};
    default:
      return new byte[]{0x01, (byte) 0xB0};
    }
  }

  private byte toIFAmpGain(int ifAmpGain) {
    switch (ifAmpGain) {
    case 12:
      return 0x00;
    case 18:
      return 0x01;
    case 21:
      return 0x02;
    case 24:
      return 0x03;
    case 27:
      return 0x04;
    case 30:
      return 0x05;
    case 36:
      return 0x06;
    case 40:
      return 0x07;
    default:
      Log.w(TAG, "Could not parse the IF AMP Gain " + ifAmpGain + " return default 36dB -> 0x06");
      return 0x06;
    }
  }

  private byte toMixerGain(int mixerGain) {
    switch (mixerGain) {
    case 0:
      return 0x00;
    case 3:
      return 0x01;
    case 6:
      return 0x02;
    case 9:
      return 0x03;
    case 12:
      return 0x04;
    case 15:
      return 0x05;
    case 16:
      return 0x06;
    default:
      //Log.w(TAG, "Could not parse the mixerGain " + mixerGain + " return default 9dB -> 0x03");
      return 0x03;
    }
  }
}