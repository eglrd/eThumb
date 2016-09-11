import processing.video.*;

// -- DIRTY PROGRAMMING (sorry) -----
// here declared parameters are used to "communicate"
// parameters to differents objects...
// ... to pass messages between remote and tv
String remoteMessage ="";
// ... index of passed message (to take into account only new messages)
// (could be coded on 2 values >> TODO)
int messageIndex=0;
// ... memorized index to check if index has changed
int messageReadIndex=0;
String thisSketchPath;
// -----------------------------------


char aBOTTOM= 'B';
char aTOP= 'T';
char aLEFT= 'L';
char aRIGHT= 'R';
char aPLAYPAUSEOK='P';
char aVOLUME='V';
char aCHANNEL='C';
char aPLUS='+';
char aMINUS='-';


// Couleurs du trackpad
color wireColor = color(5);
color bgColor = color(100);

// Couleurs du doigt virtuel
color overFillColor = color(60, 125);
color downFillColor = color(255, 0, 0);
color draggedFillColor = color(255, 255, 0);
color fingerColor = overFillColor;

// taille des boutons
int buttonWidth = 60;

// distance minimale pour activer la prise en compte du dragging
int NODRAGDISTANCE = buttonWidth/10;
int distance = 0;

// booleens qui stockent les stats
boolean MOUSEPRESSED = false; 
boolean MOUSEDRAGGED = false; 

// constantes
int MILLISBUFFERINGTIME = 600;
int MILLISREAPEATTIME = 120;

// variables globales
int millisCounterPressed = 0;
int millisCounterReleased = millisCounterPressed;

// positions du centre du doigt
int startDPointX;
int startDPointY;
int currentPointX;
int currentPointY;

// typo d'affichage
PFont font;
int textStatus = 0;
int textRemain = 0;
int TEXTFRAMEMAX = 15;
String feedBackText = "touch me"; 
int textColor = 0;

// ----------------------------------
// Setup : initialisation
// ----------------------------------
public void setup() { 
  surface.setSize(180,240);
  noCursor();
  smooth();
  frameRate(30);

  font = loadFont("/Users/etienne/Documents/eDev/eThumb/data/MarkeEigenbauNormal-8.vlw"); 
  textFont(font); 
  textSize(8);
  textAlign(CENTER);
  //textMode(SCREEN);  
 
  String[] args = {"SecondApplet"};
  TVApplet sa = new TVApplet();
  PApplet.runSketch(args, sa);
}
 
// ----------------------------------
// DRAW : la boucle principale
// ----------------------------------
void draw(){
  // affichage des reperes (qui disparaitront)
  stroke(wireColor);
  noFill();
  //line(0, height/2, width, height/2);
  //line(width/2, 0, width/2, height);
  // P+ & P-
  ellipse(width/2, 0.9*height/4, buttonWidth,buttonWidth);
  ellipse(width/2, 3.1*height/4, buttonWidth,buttonWidth);
  // Vol+ & Vol-
  ellipse(width/4, height/2, buttonWidth,buttonWidth);
  ellipse(3*width/4, height/2, buttonWidth,buttonWidth);
  // OK, Pause, Play
  //ellipse(width/2, height/2, 1*buttonWidth/2,1*buttonWidth/2);

// pour laisser une trace frimouille...
  fill(bgColor, 60);
  rect(0, 0, width, height);

// Affichage du feedback tlecommande
// c'est compliqu parce que fade in / fade out...
// le statut de la zappette
  // avant l'allumage
  
  remoteMessage="";
  
  if(feedBackText == "touch me"){
    if(textStatus == 0){
      // fade in
      if (textColor < 255-(255/TEXTFRAMEMAX)){
            textColor = textColor + (255/TEXTFRAMEMAX);
         } else {
           // ici on fixe la dure de l'affichage
           if(textRemain < 2*TEXTFRAMEMAX){
             textRemain = textRemain + 1;
           } else {
             textRemain=0;
             textStatus = 1;
           }
         }
    } else {
      // fade out
      if (textStatus <= TEXTFRAMEMAX){
         if (textColor > TEXTFRAMEMAX){
            textColor = textColor - 255/TEXTFRAMEMAX;
         } else {
           textColor = 0;
         }
      }
      textStatus = textStatus + 1; 
    }
    // ici on fixe la dure du black
    if (textStatus >= 4*TEXTFRAMEMAX){
      textStatus = 0;
    }
  } else {
    // gestion du feedback apres la premiere action
    if(textStatus == 0){
        textColor = 255;
        textStatus = 1;
    } else {
      // fade out
      if (textStatus <= TEXTFRAMEMAX){
         if (textColor > TEXTFRAMEMAX){
            textColor = textColor - 255/TEXTFRAMEMAX;
         } else {
           textColor = 0;
         }
      }
      textStatus = textStatus + 1; 
    }
    if (textColor == 0){
      feedBackText = "";
    }

  }
  fill(textColor);
  // l'affichage minimal du feedback sur la tlcommande
  // > il faut essayer pour savoir ou il serait le plus efficace
  text(feedBackText, width/2, height/2);


// trace du doigt  
  fill(fingerColor);
  noStroke();
  int eX = mouseX;
  int eY = mouseY;

  pushMatrix();
  translate(eX, eY);
  // rotation du doigt
  rotate(((eX-eX/2)*PI/4)/width);
  rotate(-(eY*PI/2)/height);
  // taille de l'empreinte rduite si le doigt est point
  float totalHeight = height;
  float scaleY = 1-(eY/(totalHeight*2));
  scale(scaleY, scaleY);
  // taille du doigt  
  int eWidth = 70;
  int eHeight = 100;

  ellipse(0, 0, eWidth, eHeight);

  popMatrix();
  
  //si le doigt reste enfonc, je dclenche un compteur qui teste le seuil pour 
  //passer en mode repeat
  if (MOUSEPRESSED){
    int millisCounterHolded = millis();
    int millisHolded = millisCounterHolded-millisCounterPressed;
    if (millisHolded > MILLISBUFFERINGTIME){
        if (millisHolded%MILLISREAPEATTIME < MILLISREAPEATTIME/3){

          // ########################## bloc similaire a ci-dessous > faire fct.
          // ### TODO ### Ajouter play/pause/select... 
          // on gere d'abord P+ / P-
          if( (mouseX>((width/2)-30))&&(mouseX<(width/2)+30)){
            // P+
            if ( (mouseY>((0.9*height/4)-buttonWidth/2))&&(mouseY<((0.9*height/4)+buttonWidth/2) )){
              //println("Ch+");
              textStatus = 0;
              feedBackText = "Ch+";
              messageIndex++;
              remoteMessage=aCHANNEL+"::"+aPLUS;
            }
            // P-
            if ( (mouseY>((3.1*height/4)-buttonWidth/2))&&(mouseY<((3.1*height/4)+buttonWidth/2) )){
             // println("Ch-");
             textStatus = 0;
             feedBackText = "Ch-";
             messageIndex++;
             remoteMessage=aCHANNEL+"::"+aMINUS;
            }
          }
    
          // on gere ensuite Vol+/Vol- (pas en exclusif because surfaces connexes)
          if( (mouseY>((height/2)-buttonWidth/2))&&(mouseY<((height/2)+buttonWidth/2))){
            // Vol-
            if((mouseX>((width/4)-buttonWidth/2))&&(mouseX<((width/4)+buttonWidth/2))){
              
              textStatus = 0;
              feedBackText = "Vol-";
              messageIndex++;
              remoteMessage=aVOLUME+"::"+aMINUS;
            }
            // Vol+
            if((mouseX>((3*width/4)-buttonWidth/2))&&(mouseX<((3*width/4)+buttonWidth/2))){
              //println("Vol+");
              textStatus = 0;
              feedBackText = "Vol+";
              messageIndex++;
              remoteMessage=aVOLUME+"::"+aPLUS;
            }
          }

          // on gere enfin Pause/Play (pas en exclusif because surfaces connexes)
          if( (mouseY>((height/2)-buttonWidth/4))&&(mouseY<((height/2)+buttonWidth/4))){
            // OK, Play, Pause
            if((mouseX>((width/2)-buttonWidth/4))&&(mouseX<((width/2)+buttonWidth/4))){
              // println("P/P OK");
              textStatus = 0;
              feedBackText = ">II";
              messageIndex++;
              remoteMessage=aPLAYPAUSEOK+"::" ;
            }
          }
          // fin des commandes simples
          // ########################## bloc similaire a ci-dessous > faire fct.
          
        }
    }
  } else if (MOUSEDRAGGED){
    
    currentPointY = mouseY;
    currentPointX = mouseX;
 
    // je ne fais rien tant que je n'ai pas dpass un drag d'une NODRAGDISTANCE donne
    distance = abs(startDPointX - currentPointX) + abs(startDPointY - currentPointY);
    if(distance > NODRAGDISTANCE*2){
      
      // on va dterminer d'ou part l'action pour savoir quelles commandes sont acceptes
      // on gere d'abord les actions haut / bas
      if( (startDPointX>((width/2)-30))&&(startDPointX<(width/2)+30)){
          // Drag du haut vers le bas
          // je trace la distance parcourue comme proprit du dploiement de l'interface
          // si le dplacement va bien vers le bas je traque la distance totale parcourue
         if ( (startDPointY>((0.9*height/4)-buttonWidth/2))&&(startDPointY<((0.9*height/4)+buttonWidth/2) )){
            int deployFactor = currentPointY - startDPointY;
            if (deployFactor > 0){
              // ### TO DO 33### n'mettre que les nouvelles valeurs au lieu d'mettre toutes les valeurs ?
                
              textStatus = 0;
              feedBackText = "more choice";
              messageIndex++;
              remoteMessage=aTOP + "::" + deployFactor ;
            }
         }
          // Drag du bas vers le haut
          // je trace la distance parcourue comme proprit du dploiement de l'interface
          // si le dplacement va bien vers le haut je traque la distance totale parcourue
          if ( (startDPointY>((3.1*height/4)-buttonWidth/2))&&(startDPointY<((3.1*height/4)+buttonWidth/2) )){
            int deployFactor = startDPointY - currentPointY ;
            if (deployFactor > 0){
                
              textStatus = 0;
              feedBackText = "more details";
              messageIndex++;
              remoteMessage=aBOTTOM + "::" + deployFactor ;
            }
         }
      } 
      
      // on gere ensuite les actions gauche / droite
      if( (startDPointY>((height/2)-buttonWidth/2))&&(startDPointY<((height/2)+buttonWidth/2))){
          // Drag de la gauche vers la droite
          // je trace la distance parcourue comme proprit du dploiement de l'interface
          // si le dplacement va bien vers la droite je traque la distance totale parcourue
         if ( (startDPointX>((width/4)-buttonWidth/2))&&(startDPointX<((width/4)+buttonWidth/2) )){
            int deployFactor = currentPointX - startDPointX;
            if (deployFactor > 0){
              // ### TO DO 33### n'mettre que les nouvelles valeurs au lieu d'mettre toutes les valeurs ?
               
              textStatus = 0;
              feedBackText = "forth";
              messageIndex++;
              remoteMessage=aLEFT+"::" + deployFactor ;
            }
         }
          // Drag de la droite vers la gauche
          // je trace la distance parcourue comme proprit du dploiement de l'interface
          // si le dplacement va bien vers la gauche je traque la distance totale parcourue
         if ( (startDPointX>((3*width/4)-buttonWidth/2))&&(startDPointX<((3*width/4)+buttonWidth/2) )){
            int deployFactor = startDPointX - currentPointX;
            if (deployFactor > 0){
              // ### TO DO 33### n'mettre que les nouvelles valeurs au lieu d'mettre toutes les valeurs ?
                
              textStatus = 0;
              feedBackText = "back";
              messageIndex++;
              remoteMessage=aRIGHT+"::" + deployFactor ;
            }
         }
      } 
      
    }
  }
}

// pour l'instant si le doigt est enfonc = mousePressed()
// dans ce framework ca ne sert qu'a dclencher le truc
void mousePressed(){
  fingerColor = downFillColor;
  MOUSEPRESSED = true;
  millisCounterPressed = millis();
}


// pour l'instant si le doigt est lev = mouseReleased()
// je place tous les lments de contr‚Ä¢le sur le mouseup
// on retrouve dans mouseReleased toutes les instructions de base
void mouseReleased() {
  fingerColor = overFillColor;
  MOUSEPRESSED = false;
  
  //remoteMessage="RELEASED::" ;
  

  // gestion du cas ou je dragge par accident une commande simple.
  // si la distance est faible je n'ai pas d'action.
  currentPointY = mouseY;
  currentPointX = mouseX;
  distance = abs(startDPointX - currentPointX) + abs(startDPointY - currentPointY);

  millisCounterReleased = millis();
  int millisHolded = millisCounterReleased-millisCounterPressed;
  if ((millisHolded > MILLISBUFFERINGTIME)){
    // ici sont gres les commandes complexes longues.
    // il ne semble pas que cette catgorie d'instruction existe pr le moment.
    // ### TODO ### virer ce test inutile ?
    // println(millisHolded + " : instruction to be handled");  
    
  } else if (!(MOUSEDRAGGED)||(distance < NODRAGDISTANCE*2)){
    // Si le doigt n'tait pas en cours de dplacement  
    // ici sont grs les commandes simples : P+, P-, Vol+, Vol- (Mute / On/Off ?)
    
    //on gere d'abord P+ / P-
    if( (mouseX>((width/2)-30))&&(mouseX<(width/2)+30)){      // P+
      if ( (mouseY>((0.9*height/4)-buttonWidth/2))&&(mouseY<((0.9*height/4)+buttonWidth/2) )){
        // println("Ch+");
        textStatus = 0;
        feedBackText = "Ch+";
        messageIndex++;
        remoteMessage=aCHANNEL+"::"+aPLUS;
      }
      // P-
      if ( (mouseY>((3.1*height/4)-buttonWidth/2))&&(mouseY<((3.1*height/4)+buttonWidth/2) )){
        // println("Ch-");
        textStatus = 0;
        feedBackText = "Ch-";
        messageIndex++;
        remoteMessage=aCHANNEL+"::"+aMINUS;
      }
    }
    
    // on gere ensuite Vol+/Vol- (pas en exclusif because surfaces connexes)
    if( (mouseY>((height/2)-buttonWidth/2))&&(mouseY<((height/2)+buttonWidth/2))){
      // Vol-
      if((mouseX>((width/4)-buttonWidth/2))&&(mouseX<((width/4)+buttonWidth/2))){
        // println("Vol-");
        textStatus = 0;
        feedBackText = "Vol-";
        messageIndex++;
        remoteMessage=aVOLUME+"::"+aMINUS;
      }
      // Vol+
      if((mouseX>((3*width/4)-buttonWidth/2))&&(mouseX<((3*width/4)+buttonWidth/2))){
        // println("Vol+");
        textStatus = 0;
        feedBackText = "Vol+";
        messageIndex++;
        remoteMessage=aVOLUME+"::"+aPLUS;
      }
    }

    // on geere enfin Pause/Play (pas en exclusif because surfaces connexes)
    if( (mouseY>((height/2)-buttonWidth/4))&&(mouseY<((height/2)+buttonWidth/4))){
      // OK, Play, Pause
      if((mouseX>((width/2)-buttonWidth/4))&&(mouseX<((width/2)+buttonWidth/4))){
        // println("P/P OK");
        textStatus = 0;
        feedBackText = ">II";
        messageIndex++;
        remoteMessage=aPLAYPAUSEOK+"::" ;
      }
    }
    // fin des commandes simples

  } 
  
  // je remets les elements lies au dragging a zero
  MOUSEDRAGGED = false;
  distance = 0;

}

// pour l'instant si le doigt est bouge = mouseDragged()
void mouseDragged() 
{
  // dans ce framework mousedragged est appele a chaque changement de direction
  // du coup je filtre pour ne pas prendre en compte les changements de direction
  // en utilisant le booleen MOUSEDRAGGED
  fingerColor = draggedFillColor;
  MOUSEPRESSED = false;
  if(!(MOUSEDRAGGED)){
    MOUSEDRAGGED = true;
    
    startDPointX = mouseX;
    startDPointY = mouseY;
    //println("start point > X : " + startDPointX + ", Y : " + startDPointY);  
    }
}
 
 
// ---------- TV screen Class -----------------------------------------------

public class TVApplet extends PApplet {
 
    String[] rOrders={""};
    String feedBack="";
    int FRAMECOUNTDELAY=4; 
    int ACCELERATION=7;
    int TCOLOR = 200;
    int FCOLOR = 220;
    
    PFont tvFont;
    
    // remoteListener : a thread capturing remote actions,
    // every int millisecond to be indep of display speed
    // this being the TVApplet monitored
    // here remote action captured every 20 ms

    RListener remoteListener;
    
    // trigering variables...    
    Boolean mDISPLAY=false; 
    Boolean bDISPLAY=false;
    Boolean rDISPLAY=false;
    Boolean lDISPLAY=false;
    Boolean bDOCK=false;
    Boolean tDISPLAY=false;
    Boolean tDOCK=false;
    Boolean pDISPLAY=false;
    Boolean pDISPLAYANIM=false;

    int strokeColor;
    
    int mainAlphac;

    int bAlphac;
    int bHeight;
    int tAlphac;
    int tHeight;
    int rAlphac;
    int pAlphac;
    int rLine;
    int lLine;


    char rTrigger;
    int bValue;
    int tValue;
    int rValue;
    int lValue;
    char wayVol;
    char wayChannel;

    Movie myMovie;

  
  public void setup() {
    surface.setSize(640,360);
    smooth();
    noStroke();
  
      
    frameRate(12); // Slow it down a little
      
    remoteListener = new RListener(20, this);
    remoteListener.start();

    myMovie = new Movie(this, "/Users/etienne/Documents/eDev/eThumb/data/toystory.mp4");
    myMovie.loop();


  }
  
    public void draw() {

       // variables
      String[] rOrderLine;

      // --------------------------------      
      // cleanup preceding frame  
      // --------------------------------
      rOrders=subset(rOrders,0,0);
      //fill(125,0,0);
      //rect(0,0, width, height);
      image(myMovie, 0, 0);
      
      // --------------------------------
      // capture remote message(0)
      // TODO : treat the fact that in some cases
      // remoteListener capture more than one message at a time
      // --------------------------------
      if (remoteListener.asReceivedNewInstruction()){              // check if a new instruction have been emitted
        rOrders = remoteListener.getRemoteInstruction();           // dump content of captured instructions
        mDISPLAY = true;                                           // triggers main display message
        mainAlphac = 255;                                              // set aplha value to start message   
      } else {
        bValue=0;  // if no isntruction received : set back values to 0
        tValue=0;  // if no isntruction received : set back values to 0
      }
      
      // --------------------------------
      // triggering events captured by remoteListener
      // --------------------------------
      if(rOrders.length>0){
        
        rOrderLine = split(rOrders[0],">>");
        
        rTrigger = rOrderLine[0].charAt(0);

        // captured char respect variables set in e0001
        switch(rTrigger){
          case 'B':
            feedBack="";
            bValue = int(rOrderLine[1]);
                                                  
            // so far if bottom is showed, hide it ;
            if (tDOCK == true){
              tHeight -=1; // should trigger the hidding of top dock..
            } else {
              // trigger bottom dock !
              bDISPLAY = true;             
            }

            //feedBack+=" "+bValue;
            break;
          case 'T':
            feedBack="";
            tValue = int(rOrderLine[1]);
            
            
            // so far if bottom is showed, hide it ;
            if (bDOCK == true){
              bHeight +=1; // should trigger the hidding of bottom dock..
            } else {
              // trigger top dock !
              tDISPLAY = true;             
            }
            
            //feedBack+=" "+tValue;
            break;
          case 'R':    //######## TODO ######## inverted wiring at last minute... renaming of variables to come
            lValue = int(rOrderLine[1]);
            if((bDISPLAY == false)&(tDISPLAY == false)&(bDOCK == false)&(tDOCK == false)){
                // then you can eventually activate rew
                feedBack="Forward";
                lDISPLAY= true;
                //feedBack+=" "+lValue;
            } else {
              // TODO manage bDOCK and tDOCK == true situations
              feedBack="<dock active>";
            }      
            break;
          case 'L':     //######## TODO ######## inverted wiring at last minute... renaming of variables to come         
            rValue = int(rOrderLine[1]);
            if((bDISPLAY == false)&(tDISPLAY == false)&(bDOCK == false)&(tDOCK == false)){
                // then you can eventually activate rew
                feedBack="Rewind";
                rDISPLAY= true;
                //feedBack+=" "+rValue;
            } else {
              // TODO manage bDOCK and tDOCK == true situations
              feedBack="<dock active>";
            }           
            break;
          case 'P':
            
            if (pDISPLAY == false){
              pDISPLAY = true; 
              feedBack="Pause";
               myMovie.pause();
            } else {
              pDISPLAY = false; 
              feedBack="Play";
              myMovie.play();
            }
            break;
          case 'V':
            feedBack="Volume";
            wayVol = rOrderLine[1].charAt(0);
            feedBack+=" "+wayVol;
            break;
          case 'C':
            feedBack="Channel";
            wayChannel = rOrderLine[1].charAt(0);
            feedBack+=" "+wayChannel;
            break;
        }
        
      }

      // --------------------------------
      // manage display accordingly     
      // --------------------------------
  

      mainDisplay();
      drawBottom();
      drawTop();
      drawRight();
      drawLeft();
      drawPause();
      
              
      
      
      
    }
  
    // Called every time a new frame is available to read
    void movieEvent(Movie m) {
      m.read();
    }  
      
    void mainDisplay(){
      if (mDISPLAY == true){
        if (mainAlphac > 0){
          fill(255,255,255, mainAlphac);
          mainAlphac -= FCOLOR/FRAMECOUNTDELAY;
        } else {
          mDISPLAY = false;
        }
      PFont tvFont = loadFont("/Users/etienne/Documents/eDev/eThumb/data/Calibri-18.vlw");
      textFont(tvFont, 18); 
      textAlign(CENTER);
      //textMode(SCREEN);
      
      text(feedBack, width/2, height/2); 
      }      
    }
    
    
    void drawBottom(){
      // bottom dispaly  (so far)
      if (bDISPLAY == true){
        if (bValue>0){
          bAlphac=TCOLOR;
          fill(200,200,200, bAlphac);
          bHeight= height-(bValue*height/160);
        
          if (bHeight<height/2){              // set a max
            bHeight = height/2;      
          } 
        }else{
          
          if(bHeight<=2*height/3){
            // here code to "freeze" basic bottom display
            bHeight += FRAMECOUNTDELAY*ACCELERATION;
            if (bHeight>2*height/3){
              bHeight=2*height/3;
              bAlphac=FCOLOR;
              
              bDOCK=true;    //the dock is shown
            }
          } else {
            // here code to hide bottom display display
            bHeight += FRAMECOUNTDELAY*ACCELERATION;
            if (bHeight>2*height/3){
              // animate bottom to "dock" it
              if (bHeight<height){               
                bAlphac=TCOLOR;
              }  else {
                bDISPLAY = false;
                bDOCK = false;
              }  

            }
          }

        }  
        
        fill(255,255,255, bAlphac-150);
        rect(0, bHeight, width, height);
        
        // ###################################################
        // bottom layout #####################################
        // simple sample here.
        // ##### TODO ##### : manage values to make them relatives
        // ###################################################
        PFont localFont;
        // title of program
        fill(255,255,255);
        localFont = loadFont("/Users/etienne/Documents/eDev/eThumb/data/Calibri-Bold-12.vlw");
        textFont(localFont, 12); 
        textAlign(LEFT);
        text("    Name of the program here", 0, bHeight + 12);  
        
        // current time
        fill(255,255,255);
        textAlign(RIGHT);
        String hSpace="";
        String mSpace="";
        int cHour = hour();
        if(cHour<10){
          hSpace="0";
        }
        int cMinute = minute();
        if(cMinute<10){
          mSpace="0";
        }
        text(hSpace+cHour+"H"+mSpace+cMinute+"    ", width, bHeight-4); 
        
        if(bDOCK==false){
          // program time
          fill(200,200,200);
          localFont = loadFont("/Users/etienne/Documents/eDev/eThumb/data/Calibri-10.vlw");
          textFont(localFont, 10);      
          text("00H00 > 00H00      ", width, bHeight+13); 

        
          // casting
          fill(200,200,200);
          textAlign(LEFT);
          localFont = loadFont("/Users/etienne/Documents/eDev/eThumb/data/Calibri-10.vlw");
          textFont(localFont, 10);      
          text("      with Fisrtname Lastname, Firstname Lastname and Firstname Lastname", 0, bHeight + 22);  
        
          // summary
          fill(150,150,150);
          text("      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam fermentum, elit vel tempor", 0, bHeight + 35);          // line 1
          text("      varius, diam arcu ultricies ipsum, vitae semper libero libero eu nibh. Etiam porttitor iaculis", 0, bHeight + 45);        // line 1
          text("      justo. Praesent ipsum odio, faucibus id, sollicitudin non, aliquam eleifend, arcu. Donec magna ", 0, bHeight + 55);            // line 1
          text("      tortor, convallis a, accumsan sit amet, convallis eu, magna. Nullam ut lacus.  Maecenas gravida ", 0, bHeight + 65);  // line 1
          text("      porta diam. Ut laoreet ligula in augue. Curabitur tincidunt convallis tellus. Donec et libero.", 0, bHeight + 75);      // line 1
          text("      Mauris euismod orci sed turpis. Cras nibh. ", 0, bHeight + 85);      // line 1
        } else {
          // rectangles figuring program segments
          // ##### TODO ##### manage dock animation here
          int rWidth = width/5;
          int rHeight= height/5;
          
          //main rectangle(current)
          fill(255,255,255, 150);
          rect(width/2 - rWidth/2, bHeight+height/16, rWidth, rHeight);
          textAlign(CENTER);
          localFont = loadFont("/Users/etienne/Documents/eDev/eThumb/data/Calibri-10.vlw");
          textFont(localFont, 10);      
          text("Name of the chapter/sequence can fit here", width/2, bHeight+height/16+rHeight+12 );


          // other rects : prev/next
          rWidth = rWidth-rWidth/14;
          rHeight = rHeight-rHeight/14;
          fill(255,255,255, 80);
          // prev
          rect((width/2 - rWidth/2) - rWidth - width/42, bHeight+height/15, rWidth, rHeight);
          // next
          rect((width/2 - rWidth/2) + rWidth + width/42, bHeight+height/15, rWidth, rHeight);
          fill(255,255,255, 40);
          // anteprev
          rect((width/2 - rWidth/2) - 2*rWidth - width/42-width/200, bHeight+height/15, rWidth, rHeight);
          // afternext
          rect((width/2 - rWidth/2) + 2*rWidth + width/42+width/200, bHeight+height/15, rWidth, rHeight);

          
        }

        // ###################################################       
        // end of bottom layout ##############################
        // ###################################################
        
        
       fill(255,255,255, bAlphac);
      }
    
    }

    void drawTop(){
      // top dispaly  (so far)
      if (tDISPLAY == true){
        if (tValue>0){
          tAlphac=TCOLOR;
          fill(255,255,255, tAlphac);
          tHeight= tValue*height/160;
        
          if (tHeight>2*height/3){              // set a max
            tHeight = 2*height/3;      
          } 
        }else{
          
          if(tHeight<height/2){
            // here code to hide top display display
            tHeight -= FRAMECOUNTDELAY*(ACCELERATION/2);
            if (tHeight<height/2){
              // animate bottom to "dock" it
              if (tHeight>0){  
     
                tAlphac=TCOLOR;
              }  else {
                
                tDISPLAY = false;
                tDOCK = false;
              }  

            }

          } else {
            // here code to "freeze" basic top display
            tHeight -= FRAMECOUNTDELAY*(ACCELERATION/2);
            if (tHeight<height/2){
              tHeight=height/2;
              tAlphac=FCOLOR;
              
              tDOCK=true;    //the dock is shown
            }
          }

        }  
        fill(255,255,255, tAlphac);
        rect(0, 0, width, tHeight);
      }
    
    }    
    
    void drawRight(){
      //rValue should setup speed ?
       if(rDISPLAY == true){
        rect(rLine, 0 , rValue/2, height);
        if(rValue>0){
          if (rLine>width){
            rLine = -rValue;
            rDISPLAY = false;
          }
          rLine += ACCELERATION*(rValue/5);
        }
        
      } else {
        //fade away ?
        rLine=-1;
        rValue=0;
      }
    }
    
    void drawLeft(){
      //lValue should setup speed ?
       if(lDISPLAY == true){
         rect(lLine-lValue/2, 0 , lValue/2, height);
         if(lValue>0){
           if(lLine<0){
             lLine = width;
             lDISPLAY=false;
           }
           lLine -= ACCELERATION*(lValue/5);
         }
         
       } else {
       //fade away ?
       lLine=width;
       lValue=0;
    }
  }

    void drawPause(){
      //lValue should setup speed ?
       if(pDISPLAY == true){
         //pAlphac = mainAlphac;
         if (mainAlphac > 0){                        // show pause on main display fading
           pAlphac = 255-mainAlphac;
         } else {                                    // animate pause symbol
            if ((pAlphac>0)&(pDISPLAYANIM == false)){
              pAlphac -= FCOLOR/FRAMECOUNTDELAY;
            }else{
              pDISPLAYANIM = true;
              if(pAlphac < 255){
                pAlphac += (FCOLOR/FRAMECOUNTDELAY)/2;
              } else {
                pDISPLAYANIM = false;   
              }
            }
         }
         fill(255,255,255, pAlphac);
         rect(4.5*width/12,height/3,width/12, height/3);
         rect(4.5*width/12+(2*width/12),height/3,width/12, height/3);
         fill(255,255,255, mainAlphac);              // get back filling to std color for other functions
       }
    }
  
  
  
}

// -------- RLinstener class (state machine)

public class RListener extends Thread implements Runnable {
  
      private boolean running;               // Is the thread running?  Yes or no?
      private int wait;                      // How many milliseconds should we wait in between executions?
      private TVApplet tv;                   // the TVApplet the listener is linked to

      private String[] remoteArgs = {""};    // table keeping capturing remote messages 
      private String[] feedBack ;          // string capturing lastest instruction

      private Boolean INSTR_AS_CHANGED=false; // stores status 
      
      // constructor 
      public RListener(int w, TVApplet argTv) {
         wait=w;
         tv=argTv;         
      }
      
      // Overriding "start()"
      public void start ()
      {
          // Set running equal to true
          running = true;
          // Print messages
          // System.out.println("Starting thread (will execute every " + wait + " milliseconds.)");
          // println("started Remote Listener");
          // Do whatever start does in Thread, don't forget this!
          super.start();
          feedBack= new String[0];
      }

      // We must implement run, this gets triggered by start()
      public void run ()
      {
          while (running){
            
            // lessoning to remote messages, sorting actions 
            if((remoteMessage!="")&(messageIndex!=messageReadIndex)){
              
              INSTR_AS_CHANGED=true;
  
              remoteArgs = split(remoteMessage, "\n");
              
              // -------
                             // reset to be placed at the end ?
              // -------
            
              // >> tt basé sur remoteArgs[0] ?;      
              String[] argCollectionTable = split(remoteArgs[0], "::");
              feedBack = splice(feedBack, argCollectionTable[0],0); 
                if (argCollectionTable.length>1){
                  feedBack[0]+=">>" + argCollectionTable[1];
                }
            
              // what to do with messages is decided here
              // print(messageIndex +" : ");
            
              messageReadIndex = messageIndex;
            
              // println(tv.feedBack);
            }

            // Ok, let's wait for however long we should wait
            
            try {
                  sleep((long)(wait));
            } catch (Exception e) {
            }
            
              
          }
          
          
          println(" thread is done!");  // The thread is done when we get to the end of run()
      }
      
      
      // the string capturing latest instruction so far...
      public String[] getRemoteInstruction()
      {
        // instruction to be transmitted, flushing previous values
        INSTR_AS_CHANGED = false;  
        
        //println(feedBack.length);
        
        String[] tempoArray = feedBack;
        feedBack = subset(feedBack,0,0);
        
 
        return tempoArray;
      }          
      
      // the boolean capturi
      public Boolean asReceivedNewInstruction()
      {
        return INSTR_AS_CHANGED;
      }
      
}