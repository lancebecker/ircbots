# -----------------------------------------------------------------
# CONFIG
# -----------------------------------------------------------------

irc = require 'irc'
auth = require './login'

opts =
  channel :'#coolkidsusa'
  botName: 'quezacotl'
  whiteList : ['quezacotl', 'hswe']
  blackList: []

flags =
  eyeForEye: false

client = new irc.Client('irc.freenode.net', opts.botName,
  debug: true
  userName: opts.botName
  channels: [opts.channel]
)

auth.login(client)

# -----------------------------------------------------------------
# SPEECH HELPERS
# -----------------------------------------------------------------

speech =
  prompts:
    introduction: 'I DEMAND A SACRIFICE, whose blood shall be spilt?'
    whitelist: 'NOPE NOT TODAY'
    blacklist: 'YOU DA BAD BOI'
    accept: 'I would have sacrificed that idiot too!'
  kicks:
    whitelist: 'GET BACK TO WORK WEAKLING'
    blacklist: 'ʕ•ᴥ•ʔ U NAUGHTY'
    victim: '(｡◕‿◕｡) BYE! (｡◕‿◕｡)'
    murderer: '¯\_(⊙︿⊙)_/¯!'
  settings:
    setefe: 'enabled: DOUBLE NERD CARNAGE'
    unsetefe: 'enabled: no consequences'
    setblacklist: 'TIMEOUT TIME'
    clear: "Can't we all be friends?"
  
# -----------------------------------------------------------------
# HELPERS
# -----------------------------------------------------------------

Helpers =
  kickUser : (user, message, delay=0) ->

    setTimeout(->
      client.send('KICK', opts.channel, user, message)
    , delay)

  sacrificer : (nick, to, s) ->
    sacrifice = s.substring(9)

    if flags.eyeForEye
      client.say to, "#{nick}.. #{speech.prompts.accept}"
      @.kickUser(sacrifice, speech.kicks.victim, 2000)
      @.kickUser(nick, speech.kicks.murderer, 2000)
    else
      client.say to, "#{nick}.. #{speech.prompts.accept}"
      @.kickUser(sacrifice, speech.kicks.victim, 2000)

  modes : (nick, to, message) ->
    if message.match(/^set eyeforeye$/i)
      client.say to, "#{nick} #{speech.settings.setefe}"
      flags.eyeForEye = true
      console.log 'SET: eyeForEye'

    if message.match(/^unset eyeforeye$/i)
      client.say to, "#{nick} #{speech.settings.unsetefe}"
      flags.eyeForEye = false
      console.log 'UNSET: eyeForEye'

    if message.match(/timeout \w*/i)
      target = message.substring(8)
      client.say to, "#{target} #{speech.settings.setblacklist}"
      opts.blackList.push(target)
      console.log 'BLACKLIST:', opts.blackList

    if message.match(/^clear$/i)
      client.say to, "#{nick} #{speech.settings.clear}"
      opts.blackList = []
      console.log 'BLACKLIST:', opts.blackList

    if message.match(/^protect \w*/i)
      target = message.substring(8)
      opts.whiteList.push(target)
      console.log 'WHITELIST:', opts.blackList


# -----------------------------------------------------------------
# EVENTS
# -----------------------------------------------------------------

client.addListener 'error', (message) ->
  console.error 'Error:', message


client.addListener 'message', (nick, to, message) ->

  if nick is 'hswe'
    Helpers.modes(nick, to, message)

  if message.match /sacrifice \w/i
    whitelist = opts.whiteList.join('|')
    blacklist = opts.blackList.join('|')

    # super greasy, super nice
    sacrifice = message.substring(9)

    if message.match(whitelist)
      client.say to, "#{nick} #{speech.prompts.whitelist}"
      Helpers.kickUser(nick, speech.kicks.whitelist, 2000)
      return false

    if nick.match(blacklist) and blacklist.length > 0
      client.say to, "#{nick} #{speech.prompts.blacklist}"
      Helpers.kickUser(nick, speech.kicks.blacklist, 2000)
      return false

    else
      Helpers.sacrificer(nick, to, message, sacrifice)

