package org.kaspernj.mirah.erb2mirah

import mirah.stdlib.*
import org.junit.Test

class TestMirah2Erb
  $Test
  def testMirah2erb:void
    path = "/home/kaspernj/Dev/Java/Eclipse/erb2mirah/src/test/resources/"
    
    puts "Spawning"
    erb = Erb2mirah.new(
      "fpath" => "#{path}test.mirah.erb",
      "package" => "org.kaspernj.mirah.erb2mirah.generated",
      "pre_path" => path
    )
    
    puts "Converting"
    erb.convert
    
    puts "Printing result"
    puts "Result: #{erb.to_s}"
    
    erb.save_to_path("/home/kaspernj/Dev/Java/Eclipse/busa/src/test/mirah/pages")
    
    
    erb = Erb2mirah.new(
      "fpath" => "#{path}test_import.mirah.erb",
      "package" => "org.kaspernj.mirah.erb2mirah.generated",
      "pre_path" => path
    )
    erb.convert
    erb.save_to_path("/home/kaspernj/Dev/Java/Eclipse/busa/src/test/mirah/pages")
  end
end