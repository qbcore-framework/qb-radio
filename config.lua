Config = {}

Config.RestrictedChannels = {
  [482] = {
    police = true
  },
  [470] = {
    ambulance = true
  },
  [858] = {
    police = true,
    ambulance = true
  }
} 

Config.MaxFrequency = 500

Config.messages = {
  ['not_on_radio'] = 'Your not connected to a signal',
  ['on_radio'] = 'Your already connected to this signal',
  ['joined_to_radio'] = 'Your connected to: <b>',
  ['restricted_channel_error'] = 'You can not connect to this signal!',
  ['invalid_radio'] = 'This frequency is not available.',
  ['you_on_radio'] = 'Your already connected to this channel',
  ['you_leave'] = 'You left the channel.'
}
