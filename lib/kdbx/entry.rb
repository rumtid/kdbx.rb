require "time"
require "base64"

class Kdbx
  class Entry
    def initialize(element)
      @element  = element
      @readonly = false
      @detached = false
    end

    def to_xml
      fmt = REXML::Formatters::Pretty.new 2, true
      fmt.compact, xml = true, ""
      fmt.write @element, xml
      xml
    end

    def uuid
      @element.text("UUID")&.strip
    end

    def iconid
      @element.text("IconID")&.to_i
    end

    def iconid=(id)
      modification do
        iconid_ele = @element.elements["IconID"]
        iconid_ele = @element.add_element("IconID") if iconid_ele.nil?
        iconid_ele.text = id.to_i
      end
    end

    def customicon
      return nil if (ele = @element.elements["CustomIconUUID"]) == nil
      ele = @element.elements["//CustomIcons/Icon/UUID[text()='#{ele.text}']"]
      Base64.strict_decode64 ele.text("../Data").strip
    end

    def customicon=(data)
      modification do
        if data == nil
          @element.delete_element "CustomIconUUID"
          break
        end

        data = Base64.strict_encode64 data.to_s
        ele = @element.elements["//CustomIcons/Icon/Data[text()='#{data}']"]

        if ele == nil
          begin
            icon_uuid = Base64.strict_encode64 Random.new.bytes 16
            ele = @element.elements["//UUID[text()='#{icon_uuid}']"]
          end while ele != nil

          icon_ele = @element.elements["//CustomIcons"].add_element "Icon"
          icon_ele.add_element("UUID").text = icon_uuid
          icon_ele.add_element("Data").text = data
        else
          icon_uuid = ele.text("../UUID").strip
        end

        ele = @element.elements["CustomIconUUID"]
        ele = @element.add_element "CustomIconUUID" if ele == nil
        ele.text = icon_uuid
      end
    end

    def creationtime
      time = @element.text("Times/CreationTime")
      time.nil? ? nil : Time.xmlschema(time)
    end

    def lastmodificationtime
      time = @element.text("Times/LastModificationTime")
      time.nil? ? nil : Time.xmlschema(time)
    end

    def lastaccesstime
      time = @element.text("Times/LastAccessTime")
      time.nil? ? nil : Time.xmlschema(time)
    end

    def locationchangedtime
      time = @element.text("Times/LocationChanged")
      time.nil? ? nil : Time.xmlschema(time)
    end

    def expirytime
      time = @element.text("Times/ExpiryTime")
      time.nil? ? nil : Time.xmlschema(time)
    end

    def expires
      text = @element.text("Times/Expires")
      text.nil? ? nil : text.strip == "True"
    end

    def usagecount
      @element.text("Times/UsageCount")&.to_i
    end

    def attributes
      hash = {}
      @element.each_element("String") do |element|
        key = element.elements["Key"]
        next if key.nil? || key.text.nil?
        hash[key.text] = element.elements["Value"].text
      end
      hash
    end

    def [](key)
      @element.text("String[Key/text()='#{key}']/Value")
    end

    def []=(key, value)
      modification do
        if (ele = @element.elements["String[Key/text()='#{key}']/Value"]) == nil
          ele = @element.add_element "String"
          ele.add_element("Key").text = key
          ele = @element.add_element "Value"
        end
        ele.text = value
      end
    end

    %w[Title UserName Password URL Notes].each do |key|
      define_method(:"#{key.downcase}") do
        self.[](key)
      end

      define_method(:"#{key.downcase}=") do |value|
        self.[]=(key, value)
      end
    end

    def history
      array = []
      @element.each_element("History/Entry") do |ele|
        entry = Kdbx::Entry.new ele
        entry.instance_variable_set :@readonly, true
        array << entry
      end
      array.sort_by! { |entry| entry.lastmodificationtime }
    end

    private

    def modification
      fail "read only entry" if @readonly

      if (history_ele = @element.elements["History"]) != nil
        previous_ele = @element.deep_clone
        previous_ele.delete_element "History"
      end

      yield

      if history_ele != nil
        history_ele.add_element previous_ele
      end

      time = Time.now.utc.xmlschema
      if (ele = @element.elements["Times/LastModificationTime"]) != nil
        ele.text = time
      end
      if (ele = @element.elements["Times/LastAccessTime"]) != nil
        ele.text = time
      end

      self
    end
  end
end
