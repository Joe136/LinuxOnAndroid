package org.joe136.linuxexecutor.data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Helper class for providing sample content for user interfaces created by
 * Android template wizards.
 * <p>
 * TODO: Replace all uses of this class before publishing your app.
 */
public class Distributions {

   public static class Distribution {
      private static int id_counter = 0;
      public Integer id;
      public String content;

      public Distribution(String content) {
         ++id_counter;
         this.id = id_counter;
         this.content = content;
      }

      @Override
      public String toString() {
         return content;
      }
   }//end Class



   /**
    * An array of sample (dummy) items.
    */
   public static List<Distribution> ITEMS = new ArrayList<Distribution>();



   /**
    * A map of sample (dummy) items, by ID.
    */
   public static Map<Integer, Distribution> ITEM_MAP = new HashMap<Integer, Distribution>();



   static {
      // Add 3 sample items.
      addItem(new Distribution("Ubuntu"));
      addItem(new Distribution("Debian"));
      addItem(new Distribution("Arch"));
   }



   public static void addItem(Distribution item) {
      ITEMS.add(item);
      ITEM_MAP.put(item.id, item);
   }//end Fct

}//end Class
