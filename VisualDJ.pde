import hypermedia.video.*;
import java.awt.*;
import com.google.zxing.*;
import java.awt.image.*;
import ddf.minim.*;

OpenCV opencv;
com.google.zxing.Reader reader = new com.google.zxing.MultiFormatReader();

LuminanceSource source;
BinaryBitmap bitmap;
Result result;

Set<Integer> tempList;
Set<Integer> activeList;

Map<Integer, AudioPlayer> players;
Minim minim;

Map<Integer, String> soundList;

void setup() {

  minim = new Minim(this);

  players = new HashMap<Integer, AudioPlayer>();
  soundList = new HashMap<Integer, String>();

  initSoundList();

  activeList = new HashSet<Integer>();
  tempList = new HashSet<Integer>();

  size(640, 480);

  opencv = new OpenCV(this);
  opencv.capture(width / 2, height / 2);

  ellipseMode(CENTER);
  textAlign(CENTER);
}

void draw() {

  background(0);

  opencv.read();

  image(opencv.image(), width / 2, 0);

  opencv.threshold(80);

  image(opencv.image(), 0, height / 2);

  Blob[] blobs = opencv.blobs(0, (width * height), 10, true); 

  for (Blob b : blobs) {

    if ( b.isHole && b.area > 5000 ) {
      noFill();
      stroke(255);

      beginShape();
      for (int i = 0; i < b.points.length; i++) {
        vertex( b.points[i].x, b.points[i].y);
      }
      endShape(CLOSE);

      Rectangle r = b.rectangle;
      Point c = b.centroid;

      PImage crop = get(r.x + (width / 2), r.y, r.width, r.height);
      image(crop, r.x + (width / 2), r.y + (height / 2));

      fill(0, 255, 0);
      text( b.area, c.x, c.y);

      // QR Read     
      source = new BufferedImageLuminanceSource((BufferedImage) crop.getImage() );
      bitmap = new BinaryBitmap(new HybridBinarizer(source));

      try {
        result = reader.decode(bitmap);

        if (result.getText() != null) {       
          addValue( result.getText() );
        }
      } 
      catch(Exception e) {
      }
    }
  }

  refreshValues();
}

void addValue(String value) {  
  tempList.add( Integer.valueOf(value) );
}

void refreshValues() {
  activeList.addAll( tempList );

  Collection<Integer> disjunction = (Collection<Integer>) CollectionUtils.disjunction(activeList, tempList);

  activeList.removeAll( disjunction );

  for (Integer active : activeList) {

    AudioPlayer player = players.get( active );

    if (player == null) {

      player = minim.loadFile( soundList.get( active ), 512 );
      player.loop();

      players.put( active, player );
    }
  }

  for (Integer deactive : disjunction) {

    AudioPlayer player = players.remove( deactive );
    player.close();
  }

  tempList.clear();
}

void stop() {

  for (AudioPlayer player : players.values()) {
    player.close();
  }

  minim.stop();
  super.stop();
}

void initSoundList() {

  soundList.put(1, "beat1_boom_a.mp3");
  soundList.put(2, "beat1_boom_b.mp3");
  soundList.put(3, "beat4_ptttpeu_a.mp3");
  soundList.put(4, "beat4_ptttpeu_b.mp3");
  soundList.put(5, "beat5_slupttt_a.mp3");
  soundList.put(6, "coeur1_oaaah_a.mp3");
  soundList.put(7, "coeur1_oaaah_b.mp3");
  soundList.put(8, "coeur2_cougou_a.mp3");
  soundList.put(9, "coeur2_cougou_b.mp3");
  soundList.put(10, "effet1_poulll_a.mp3");
  soundList.put(11, "effet2_tucati_a.mp3");
  soundList.put(12, "effet4_tululou_a.mp3");
  soundList.put(13, "melo1_nananana_a.mp3");
  soundList.put(14, "melo2_pelulu_a.mp3");
  soundList.put(15, "melo3_siffle_a.mp3");
  soundList.put(16, "melo4_tatouti_a.mp3");
  soundList.put(17, "melo5_tvutvutvu_a.mp3");
  soundList.put(18, "voix1_isit_a.mp3");
  soundList.put(19, "voix2_uare_a.mp3");
}

void devMode() {
}

