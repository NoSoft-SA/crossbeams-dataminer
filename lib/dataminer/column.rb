module Dataminer

  class Column
    attr_accessor :name, :sequence_no, :caption, :namespaced_name, :data_type

    def initialize(sequence_no, parse_path, options={})
      @name         = get_name(parse_path)
      @namespaced_name = get_namespaced_name(parse_path)
      @sequence_no  = sequence_no
      @parse_path   = parse_path
      @caption      = name.sub(/_id\z/, '').tr('_', ' ').sub(/\A\w/) { |match| match.upcase }
      @width        = options[:width]
      @data_type    = options[:data_type]    || :string
      @format       = options[:format]
      @hide         = options[:hide]         || false

      @groupable    = options[:groupable]    || false
      @group_by_seq = options[:group_by_seq]
      @group_sum    = options[:group_sum]    || false
      @group_avg    = options[:group_min]    || false
      @group_min    = options[:group_max]    || false
    end

    def self.create_from_parse(seq, path)
      new(seq, path)
    end

    def to_hash
      hash = {}
      [:name, :sequence_no, :caption, :namespaced_name, :data_type].each {|a| hash[a] = self.send(a) }
      hash
    end

    def modify_from_hash(column)
      self.sequence_no     = column[:sequence_no]
      self.namespaced_name = column[:namespaced_name]
      self.data_type       = column[:data_type]
      self.caption         = column[:caption]
    end

    private

    def get_name(restarget)
      if restarget['name']
        restarget['name']
      else
        if restarget['val']['FUNCCALL']
          restarget['val']['FUNCCALL']['funcname'].last
        else
          fld = restarget['val']['COLUMNREF']['fields'].last
          if fld.is_a? String
            fld
          else
            fld.keys[0]
          end
        end
      end
    end

    def get_namespaced_name(restarget)
      if restarget['val']['FUNCCALL']
        restarget['val']['FUNCCALL']['funcname'].join('.') #.......
      elsif restarget['val']['COLUMNREF']
        restarget['val']['COLUMNREF']['fields'].join('.')
      else
        nil # Probably a calculated field - can't be used as a query parameter
      end
    end

  end

end
