# Title: Photos tag for Jekyll
# Authors: Devin Weaver
# Description: Allows photos tag to place photos as thumbnails and open in fancybox. Uses a CDN if needed.
#
# ** This only covers the markup. Not the integration of FancyBox **
#
# To see an unabridged explination on integrating this with [FancyBox][1]
# Please read my [blog post about it][2].
#
# [1]: http://fancyapps.com/fancybox/
# [2]: http://tritarget.org/blog/2012/05/07/integrating-photos-into-octopress-using-fancybox-and-plugin/
#
# Syntax {% photo filename [tumbnail] [title] %}
# Syntax {% photos filename [filename] [filename] [...] %}
# If the filename has no path in it (no slashes)
# then it will prefix the `_config.yml` setting `photos_prefix` to the path.
# This allows using a CDN if desired.
#
# To make FancyBox work well with OctoPress You need to include the style fix.
# In your `source/_include/custom/head.html` add the following:
#
#     {% fancyboxstylefix %}
#
# Examples:
# {% photo photo1.jpg My Photo %}
# {% photo /path/to/photo.jpg %}
# {% gallery %}
# photo1.jpg: my title 1
# photo2.jpg[thumnail.jpg]: my title 2
# photo3.jpg: my title 3
# {% endgallery %}
#
# Output:
# <a href="photo1.jpg" class="fancybox" title="My Photo"><img src="photo1_m.jpg" alt="My Photo" /></a>
# <a href="/path/to/photo.jpg" class="fancybox" title="My Photo"><img src="/path/to/photo_m.jpg" alt="My Photo" /></a>
# <ul class="gallery">
#   <li><a href="photo1.jpg" class="fancybox" rel="gallery-e566c90e554eb6c157de1d5869547f7a" title="my title 1"><img src="photo1_m.jpg" alt="my title 1" /></a></li>
#   <li><a href="photo2.jpg" class="fancybox" rel="gallery-e566c90e554eb6c157de1d5869547f7a" title="my title 2"><img src="photo2_m.jpg" alt="my title 2" /></a></li>
#   <li><a href="photo3.jpg" class="fancybox" rel="gallery-e566c90e554eb6c157de1d5869547f7a" title="my title 3"><img src="photo3_m.jpg" alt="my title 3" /></a></li>
# </ul>

require 'digest/md5'

module Jekyll
  
  class PhotosUtil
    def initialize(context)
      @context = context
    end

    def path_for(filename)
      filename = filename.strip
      prefix = (@context.environments.first['site']['photos_prefix'] unless filename =~ /^(?:\/|http)/i) || ""
      "#{prefix}#{filename}"
    end

    def thumb_for(filename, thumb=nil)
      filename = filename.strip
      # FIXME: This seems excessive
      if filename =~ /\./
        thumb = (thumb unless thumb == 'default') || filename.gsub(/(?:_b)?\.(?<ext>[^\.]+)?$/, "_m.\\k<ext>")
      else
        thumb = (thumb unless thumb == 'default') || "#{filename}_m"
      end
      path_for(thumb)
    end
  end

  class FancyboxStylePatch < Liquid::Tag
    def render(context)
      return <<-eof
<!-- Fix FancyBox style for OctoPress -->
<style type="text/css">
  .fancybox-wrap { position: fixed !important; }
  .fancybox-opened {
    -webkit-border-radius: 4px !important;
       -moz-border-radius: 4px !important;
            border-radius: 4px !important;
  }
  .fancybox-close, .fancybox-prev span, .fancybox-next span {
    background-color: transparent !important;
    border: 0 !important;
  }
</style>
      eof
    end
  end

  class PhotoTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      if /(?<filename>\S+)(?:\s+(?<thumb>\S+))?(?:\s+(?<title>.+))?/i =~ markup
        @filename = filename
        @thumb = thumb
        @title = title
      end
      super
    end

    def render(context)
      p = PhotosUtil.new(context)
      if @filename
        "<a href=\"#{p.path_for(@filename)}\" class=\"fancybox\" title=\"#{@title}\"><img src=\"#{p.thumb_for(@filename,@thumb)}\" alt=\"#{@title}\" /></a>"
      else
        "Error processing input, expected syntax: {% photo filename [thumbnail] [title] %}"
      end
    end
  end

  class GalleryTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
      # No initializing needed
      super
    end

    def render(context)
      # Convert the entire content array into one large string
      lines = super.map(&:strip).join("\n")
      # Get a unique identifier based on content
      md5 = Digest::MD5.hexdigest(lines)
      # split the text by newlines
      lines = lines.split("\n")

      p = PhotosUtil.new(context)
      list = ""

      lines.each do |line|
        if /(?<filename>[^\[\]:]+)(?:\[(?<thumb>\S*)\])?(?::(?<title>.*))?/ =~ line
          list << "<li><a href=\"#{p.path_for(filename)}\" class=\"fancybox\" rel=\"gallery-#{md5}\" title=\"#{title.strip}\">"
          list << "<img src=\"#{p.thumb_for(filename,thumb)}\" alt=\"#{title.strip}\" /></a></li>"
        end
      end
      "<ul class=\"gallery\">\n#{list}\n</ul>"
    end
  end

end

Liquid::Template.register_tag('photo', Jekyll::PhotoTag)
Liquid::Template.register_tag('gallery', Jekyll::GalleryTag)
Liquid::Template.register_tag('fancyboxstylefix', Jekyll::FancyboxStylePatch)