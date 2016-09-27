import controlP5.*; //<>// //<>// //<>//

/**
 * Simple Read
 * 
 * Read data from the serial port and change the color of a rectangle
 * when a switch connected to a Wiring or Arduino board is pressed and released.
 * This example works with the Wiring / Arduino program that follows below.
 */


import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
NewSendCommendManager commendManager;
boolean bRead = false;
//control
ControlP5 cp5;
Textarea myTextarea;
Println console;
DropdownList dropListSensivitiy;
void setup() 
{
  size(800, 600);
  cp5 = new ControlP5(this);
  
  
  int posX = (int)(width*0.5);
  int posY = 10;
  
  cp5.enableShortcuts();
  frameRate(50);

  cp5.addButton("Read")
    .setValue(0)
    .setPosition(posX, posY)
    .setSize(200, 10)
    ;

  myTextarea = cp5.addTextarea("console")
    .setPosition(0, 0)
    .setSize(posX, height)
    .setFont(createFont("", 10))
    .setLineHeight(14)
    .setColor(color(200))
    .setColorBackground(color(0, 100))
    .setColorForeground(color(255, 100));
  console = cp5.addConsole(myTextarea);//


  cp5.addLabel("SENSITIVITY",posX, posY+=20);
  dropListSensivitiy = cp5.addDropdownList("SENSITIVITY_DROPLIST")
    .setPosition(posX, posY+=20);
  dropListSensivitiy.setBackgroundColor(color(190));
  dropListSensivitiy.setItemHeight(20);
  dropListSensivitiy.setBarHeight(15);
  //dropListSensivitiy.getCaptionLabel().set("SENSITIVITY");

  dropListSensivitiy.addItem("16", 0);
  dropListSensivitiy.addItem("17", 1);
  dropListSensivitiy.addItem("18", 2);
  dropListSensivitiy.addItem("19", 3);
  dropListSensivitiy.addItem("20", 4);
  dropListSensivitiy.addItem("21", 5);
  dropListSensivitiy.addItem("22", 6);
  dropListSensivitiy.addItem("23", 7);

  //ddl.scroll(0);
  dropListSensivitiy.setColorBackground(color(60));
  dropListSensivitiy.setColorActive(color(255, 128));

  bRead = false;
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  for (String portName : Serial.list()) {

    println(portName);
    if (portName.contains("cu.usbserial")) {
      myPort = new Serial(this, portName, 115200);
      break;
    }
  }
  if (myPort==null) {
    exit();
  }
  commendManager = new NewSendCommendManager(myPort);
  byte[] versionBytes = commendManager.getFirmware();
  if (versionBytes != null) {

    String version = new String(versionBytes);
    println("version "+ version);
  }
}


void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    println("event id : "+theEvent.getGroup().getId());
  } else if (theEvent.isController()) {
    if (theEvent.getController().equals(dropListSensivitiy)) {
      println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
      commendManager.setSensitivity(16+(int)theEvent.getController().getValue());
    }
  }
}

public void Read(int theValue) {
  bRead = !bRead;
}
void draw()
{
  background(0);
  readEPC();
}

void readEPC() {
  if (bRead) {
    List<EPC> epcList = commendManager.EPCRealTime();
    if (epcList != null && !epcList.isEmpty()) {

      for (EPC epc : epcList) {
        Log.i("EPC", epc.getEpc());
        Log.i("RSSI", epc.getRSSIString());
      }
    }
  }
}