# frozen_string_literal: true

require "erb"
require "optparse"
require "fileutils"
require_relative "thimble/version"

module Thimble
  class Error < StandardError; end

  class Generator
    def initialize(indir, options)
      @in_dir = indir
      @out_dir = options[:out]
      @pages = {}
    end

    def generate
      FileUtils.mkdir_p(@out_dir)

      Dir.glob(File.join(@in_dir, "**/*.txt")).each do |file|
        page_name = File.basename(file, ".txt")
        content = File.read(file)
        @pages[page_name] = {
          name: page_name,
          content:,
          links: extract_links(content),
          backlinks: []
        }
      end

      @pages.each do |name, data|
        data[:links].each do |outbound|
          next unless @pages[outbound]
          @pages[outbound][:backlinks] << name
        end
      end

      @pages.each do |name, data|
        html = wrap_html(data)
        File.write(File.join(@out_dir, "#{name}.html"), html)
      end
    end

    private

    def extract_links(content)
      content.scan(/\[\[(.*?)\]\]/).flatten.uniq
    end

    def preprocess_content(content)
      content.gsub(/\[\[(.*?)\]\]/) do |match|
        link_text = $1
        if @pages.key?(link_text)
          %(<a href="#{link_text}.html">#{link_text}</a>)
        else
          %(<a class="missing-link">#{link_text}</a>)
        end
      end
    end

    def wrap_html(data)
      template = <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title><%= title %></title>
          <style>
            .missing-link { text-decoration: underline dotted; }
          </style>
          <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">
        </head>
        <body>
          <h1><%= title %></h1>
          <main><%= content %></main>
          <% unless backlinks.empty? %>
            <h2>backlinks</h2>
            <ul>
              <% backlinks.each do |link| %>
                <li><a href="<%= link %>.html"><%= link %></a></li>
              <% end %>
            </ul>
          <% end %>
        </body>
        </html>
      HTML

      html_content = ERB.new(template)

      title = data[:name]
      content = preprocess_content(data[:content])
      backlinks = data[:backlinks]

      html_content.result(binding)
    end
  end

  class CLI
    def run
      options = {
        out: "dist/"
      }

      OptionParser.new do |p|
        p.banner = "Usage: thimble dir [options]"
        p.on("-oOUTDIR", "--out=OUTDIR", "Output directory (default: dist/)")
        p.on("-h", "--help") do
          puts p
          exit
        end
      end.parse!(into: options)

      if ARGV.length != 1
        puts parser
        exit 1
      end

      Generator.new(ARGV[0], options).generate
    end
  end
end
