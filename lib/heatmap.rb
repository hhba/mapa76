class Heatmap
  class Chunk < Array
    attr_accessor :idx

    def initialize(chunk_idx, chunk_size)
      @idx = chunk_idx
      @size = chunk_size
      super([])
    end

    def next_idx
      @idx + 1
    end

    def prev_idx
      @idx - 1
    end

    def abs_start_pos
      @idx * @size
    end

    def abs_end_pos
      abs_start_pos + @size
    end
  end

  def initialize(size, chunk_size=1000, interpolate=true)
    @size = size
    @chunk_size = chunk_size.to_i
    @chunks = Hash.new { |hash, k| hash[k] = Chunk.new(k, chunk_size.to_i) }
    @interpolate = interpolate
  end

  def add_entry(entry_pos, entry)
    chunk = Chunk.new((entry_pos.to_i / @chunk_size).to_i, @chunk_size)
    @chunks[chunk.prev_idx] << entry if @interpolate && chunk.idx > 0
    @chunks[chunk.idx] << entry
    @chunks[chunk.next_idx] << entry if @interpolate
  end

  def hot_chunks(n=10)
    @chunks.sort_by { |chunk_id, values| values.length }.reverse[0..n]
  end

  def hot_areas(n=10, max_chunks_in_area=10)
    areas = []
    in_area = []
    @chunks.each do |idx, chunk|
      in_area << chunk
      # we'll add the current "area" to the "areas" array if the chunk with the next idx is empty
      # or if the number of chunks in the area is < max_chunks_in_area
      if not @chunks.has_key?(chunk.next_idx) or @chunks[chunk.next_idx].empty? or in_area.length >= max_chunks_in_area
        areas << in_area if in_area
        in_area = []
      end
    end
    areas.map do |chunks|
      first = chunks.min_by { |chunk| chunk.idx }
      last = chunks.max_by { |chunk| chunk.idx }
      { :start => first.abs_start_pos,
        :end => last.abs_end_pos,
        :entries => chunks.flatten }
    end.sort_by { |area| area[:entries].length }.reverse[0..n]
  end
end
