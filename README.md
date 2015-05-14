# Shog

[![Gem Version](https://badge.fury.io/rb/shog.svg)](http://badge.fury.io/rb/shog)
[![Code Climate](https://codeclimate.com/github/phallguy/shog.png)](https://codeclimate.com/github/phallguy/shog)
[![Circle CI](https://circleci.com/gh/phallguy/shog.svg?style=svg)](https://circleci.com/gh/phallguy/shog)

Make rails 4.0 log details more colorful.

There are plenty of logging frameworks for making tags (like timestamp, log
level, etc.) more colorful - but what about the details in the line of text?
What about the HTTP method used to make the request? What about the render
times?

Shog adds colors to highlight context and make it easier to pick out the
important parts of the message. Unformatted logs like this

![Plain Logs](docs/images/plain.png)

become easy to ready and process logs like this

![Shogged Logs](docs/images/shogged.png)

## Using Shog

Just add the following to your Gemfile to enable shiny output logs.

```
gem 'shog'
```

Shog comes built in with some sane defaults for rails apps. But you can
customize the output  to match additional log message by your app, or to use
different options in production.

To change the defaults, add `shog.rb` to your `config/initializers` folder

```ruby
Shog.configure do
  if ::Rails.env.production?
    reset_config!
    timestamp
  end

  match /execution expired/ do |msg,matches|
    # Highlight timeout errors
    msg.red
  end
end
```

See [Shog::Formatter#configure](lib/shog/formatter.rb) for more configuration options.

## Contributing

1. Fork it ( https://github.com/phallguy/shog/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


# License

The MIT License (MIT)

Copyright (c) 2014 Paul Alexander

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.