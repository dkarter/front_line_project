import 'phoenix_html';
import { Socket } from 'phoenix';

const videoFrame = document.getElementById('video-frame');
const motionFrame = document.getElementById('motion-frame');
const socket = new Socket('/socket');
socket.connect();

const videoChannel = socket.channel('video:lobby');
videoChannel.on('next_frame', msg => {
  videoFrame.setAttribute('src', `data:image/png;base64,${msg.base64_data}`);
});

videoChannel
  .join()
  .receive('ok', resp => console.log('Joined video successfully', resp))
  .receive('error', resp => console.log('Unable to join video', resp));

const motionChannel = socket.channel('motion:lobby');
motionChannel.on('motion', motion => {
  const msg = motion.active ? 'motion detected' : 'no motion';
  motionFrame.innerText = msg;
});

motionChannel
  .join()
  .receive('ok', resp => console.log('Joined motion successfully', resp))
  .receive('error', resp => console.log('Unable to join motion', resp));
