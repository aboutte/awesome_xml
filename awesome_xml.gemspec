# coding: utf-8
Gem::Specification.new do |spec|
  spec.name = 'awesome_xml'
  spec.version = '1.2.0'
  spec.authors = ['Felix Lublasser']
  spec.email = ['felix.lublasser@fromatob.com']

  spec.summary = 'Parse data from XML documents into arbitrary ruby hashes.'
  spec.description = 'Have XML data that you want to bend to your will' \
                     'and conform to your schema? This gem is for you.'

  spec.licenses = %w(MIT)

  spec.files = Dir['lib/awesome_xml/**/*.rb',
                   'lib/awesome_xml.rb',
                   'Gemfile',
                   'LICENSE',
                   'Rakefile',
                   'README.md']
  spec.homepage = 'https://github.com/fromAtoB/awesome_xml'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.41'

  spec.add_runtime_dependency 'activesupport', '~> 6.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.3'
end