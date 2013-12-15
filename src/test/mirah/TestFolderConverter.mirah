package org.kaspernj.mirah.erb2mirah

import org.junit.Test
import mirah.stdlib.*

class TestFolderConverter
  $Test
  def testFolderConverter:void
    path = "/home/kaspernj/Dev/Java/Eclipse/erb2mirah/src/test"
    path_pre = "/home/kaspernj/Dev/Java/Eclipse/erb2mirah/src/test/"
    path_to = "/home/kaspernj/testFolderConverter"
    
    Dir.mkdir(path_to) if !File.exists?(path_to)
    
    FolderConverter.new(
      "path" => path,
      "pre_path" => path_pre,
      "path_to" => path_to,
      "package" => "org.kaspernj.mirah.erb2mirah.generated",
      "debug" => "false"
    )
  end
end