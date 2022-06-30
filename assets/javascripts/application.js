Pusher.logToConsole = true;

const pusher = new Pusher('f8902beee86dc0f3da1c', {
  cluster: 'us2',
  encrypted: true
});

const channel = pusher.subscribe('go-fish');
channel.bind('game-changed', function (data) {
  console.log(data.message);
  if (window.location.pathname === '/game') {
    window.location.reload();
  }
});