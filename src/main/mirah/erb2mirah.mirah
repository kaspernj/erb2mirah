package org.kaspernj.mirah.erb2mirah

import mirah.stdlib.File
import java.util.*

#This class converts ".mirah.erb"-files to ".mirah"-files containing a class and a method to execute the original code.
class Erb2mirah
  #Used to calculate classnames for paths.
  def self.classname_for_path(path:String)
    classname = String(path)
    classname = classname.replaceAll("\\.", "_dot_").replaceAll("\\/", "_slash_")
    return "Erb2mirah_#{classname}"
  end
  
  def initialize(args:HashMap)
    @args = args
    @fpath = String(args["fpath"])
    @package = String(args["package"])
    
    @lines = ArrayList.new
    @classname = ""
    @debug = false
  end
  
  #Converts various special characters in a string to a printable format that can be in a variable when printed.
  def convert_printline(str:String)
    return str.replaceAll("\r", "' + \"\r\" + '").replaceAll("\n", "' + \"\\\\n\" + '")
  end
  
  #Used to write debug prints if debug is enabled.
  def debug(str:String)
    puts str if @debug
  end
  
  #Enables debugging.
  def debug_enable
    @debug = true
  end
  
  #Converts a ".mirah.erb"-file to ".mirah".
  def convert
    debug "Arguments: '#{@args}'."
    
    file = File.new(@fpath)
    converted = ""
    inst = self
    mode = "printline"
    lines = @lines
    
    pattern_codestart = /^(.*)<%(.*)$/
    pattern_codeecho = /^(.*)<%=(.*)%>(.*)$/
    pattern_codeend = /^(.*)%>(.*)$/
    
    file.lines do |line|
      inst.debug "Treating line"
      lineb = StringBuffer.new
      
      if mode.equals("printline")
        matcher_codeecho = pattern_codeecho.matcher(line)
        matcher_codestart = pattern_codestart.matcher(line)
        
        if matcher_codeecho.find
          begin_print = matcher_codeecho.group(1)
          end_print = matcher_codeecho.group(3)
          
          lineb.append("self.write('#{inst.convert_printline(begin_print)}');") if begin_print.length > 0
          lineb.append("self.write(#{matcher_codeecho.group(2)});")
          lineb.append("self.puts('#{inst.convert_printline(end_print)}');") if end_print.length > 0
        elsif matcher_codestart.find
          #inst.debug "Code starts: #{matcher_codestart}"
          
          lineb.append("self.write('#{inst.convert_printline(matcher_codestart.group(1))}');")
          lineb.append(matcher_codestart.group(2))
          
          mode = "code"
        else
          lineb.append("self.write('" + inst.convert_printline(line) + "');")
        end
      elsif mode.equals("code")
        matcher_codeend = pattern_codeend.matcher(line)
        
        if matcher_codeend.find
          begin_code = matcher_codeend.group(1)
          end_print = matcher_codeend.group(2)
          lineb.append(begin_code)
          
          if end_print.length > 0
            lineb.append(";")
            lineb.append("self.puts('#{inst.convert_printline(end_print)}');")
          else
            lineb.append("self.puts('');")
          end
          
          mode = "printline"
        else
          lineb.append(line.substring(0, line.length - 1))
        end
      else
        inst.debug "Unkonwn mode: '#{mode}'."
      end
      
      lines.add(lineb.toString) if lineb.length > 0
    end
    
    return converted
  end
  
  #Adds a line of code to the array of lines.
  def add_code(line:String)
    @lines.add(line)
  end
  
  #Returns a string with a generated class-name based on the path.
  def generated_classname
    classname = String(@fpath)
    debug "Classname: '#{classname}'."
    
    if @args.containsKey("pre_path") and @args.get("pre_path") != nil
      classname = classname.replaceAll(String(@args["pre_path"]), "")
      debug "Classname after pre-path removed: '#{classname}'."
    end
    
    classname = classname.replaceAll("\\.", "_dot_").replaceAll("\\/", "_slash_")
    debug "Classname after replace: '#{classname}'."
    
    classname = "Erb2mirah_#{classname}"
    debug "Classname after prepend: '#{classname}'."
    
    return classname
  end
  
  #Returns the classname, if it has been set, else it returns the generated classname.
  def classname
    return @classname if @classname != nil and !@classname.equals("")
    return self.generated_classname
  end
  
  #Returns a string containing the start-stuff of the generated ".mirah"-file (package, class, run-code-method).
  def start_stuff
    strb = StringBuffer.new
    strb.append("package \"#{@package}\";")
    strb.append("import org.kaspernj.mirah.erb2mirah.Page;")
    strb.append("class #{self.generated_classname} < Page;")
    strb.append("def run_code:void;")
    
    return strb.toString
  end
  
  #Returns the end-stuff of the ".mirah"-file (return and various ends).
  def end_stuff
    strb = StringBuffer.new
    strb.append(";return;end;end")
    
    return strb.toString
  end
  
  #Returns the generated Mirah-code as a string.
  def to_s
    str = StringBuffer.new
    str.append(self.start_stuff)
    
    @lines.each do |line_obj|
      line = String(line_obj)
      str.append(line + "\n")
    end
    
    str.append(self.end_stuff)
    
    return str.toString
  end
  
  #Saves the generated Mirah-code to a given path.
  def save_to_path(path:String):void
    basename = File.basename(@fpath, ".mirah.erb")
    newpath = "#{path}/#{basename}.mirah"
    inst = self
    
    File.unlink(newpath) if File.exists?(newpath)
    File.open(newpath, "w") do |fp|
      fp.write(inst.to_s)
    end
  end
end