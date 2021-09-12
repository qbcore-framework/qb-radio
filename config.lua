Config = {}

Config.RestrictedChannels = 10 -- channels that are encrypted (EMS, Fire and police can be included there) if we give eg 10, channels from 1 - 10 will be encrypted

Config.MaxFrequency = 500

-- jobs that are allowed to be on Restricted channels
Config.AllowedJobs = {
  ['police'] = true,
  ['ambulance'] = true
}

Config.messages = {
  ['not_on_radio'] = 'Your not connected to a signal',
  ['on_radio'] = 'Your already connected to this signal',
  ['joined_to_radio'] = 'Your connected to: <b>',
  ['restricted_channel_error'] = 'You can not connect to this signal!',
  ['invalid_radio'] = 'This frequency is not available.',
  ['you_on_radio'] = 'Your already connected to this channel',
  ['you_leave'] = 'You left the channel.'
}