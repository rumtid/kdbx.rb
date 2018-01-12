require "set"
require "time"
require "base64"
require "rexml/document"
require_relative "entry"

class Kdbx
  class Document
    def initialize(xml, cipher = nil)
      @doc = REXML::Document.new xml

      if cipher != nil
        @doc.each_element("//Value[@Protected='True']") do |e|
          e.text = cipher.update Base64.strict_decode64 e.texts.join.strip
        end
      end
    end

    def to_xml(cipher = nil)
      doc = @doc.deep_clone

      if cipher != nil
        doc.each_element("//Value[@Protected='True']") do |e|
          e.text = Base64.strict_encode64 cipher.update e.texts.join
        end
      end

      String.new.tap { |s| doc.write s }
    end

    def name
      @doc.text("/KeePassFile/Meta/DatabaseName")
    end

    def each_entry
      if block_given?
        @doc.each_element("//Group/Entry") { |e| yield Entry.new e }
        self
      else
        Enumerator.new do |yielder|
          @doc.each_element("//Group/Entry") { |e| yielder << Entry.new(e) }
        end
      end
    end

    def clear_old_customicon
      uuids = Set.new
      @doc.each_element("//CustomIconUUID") do |ele|
        uuids.add ele.text.to_s.strip
      end

      @doc.each_element("//CustomIcons/Icon/UUID") do |ele|
        icon_uuid = ele.text.to_s.strip
        next if uuids.include? icon_uuid
        ele.parent.delete_element ele

        if (ele = @doc.elements["//DeletedObjects"]) != nil
          ele = ele.add_element "DeletedObject"
          ele.add_element("UUID").text = icon_uuid
          ele.add_element("DeletionTime").text = Time.now.utc.xmlschema
        end
      end
    end

    private

    def headerhash=(data)
      e = @doc.elements["/KeePassFile/Meta/HeaderHash"]
      e.text = Base64.strict_encode64 data.to_s if e != nil
      self
    end
  end
end
