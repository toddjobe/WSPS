# requires pysox

from sys import stdout  
import ConfigParser
import pysox

defaults={
    'videoStream': 'udp://localhost:1234',
    'audioDevice': 'default',
    'localFolderBase': '/Users/toddjobe/Documents/AudioFiles', 
    'localFolderBase': '/Users/sunraes/Desktop/AudioFile', 
    'remoteFolder': '%(localFolderBase)/remote', 
    'itoffset': 0,
    'user': 'sunraes',
    'host': 'peopleforjesus.org',
    'audioFormat': 'mp3'}

# Parse configuration file
config = ConfigParser.SafeConfigParser(defaults)
config.read('wsps.cfg')

# add folder storage stuff here

# callback for multithread audio recording
def callback(in_data, frame_count, time_info, status):
    r.extend(in_data)
    # handle errors here from status    
    # query the recordFlag
    return (data, recordFlag)
def record():
    p = pyaudio.PyAudio()
    stream = p.open(format=audioFormat, channels=1, rate=RATE, input=True, output=True, frames_per_buffer=CHUNK_SIZE)
    r = array('h')
    while 1:
        #little endian, signed short
        snd_data = array('h', stream.read(CHUNK_SIZE))
        if byteorder == 'big':
            snd_data.byteswap()
        r.extend(snd_data)
        if condition:  
            break
    stream.stop_stream()
    stream.close()
    p.terminate()



hAudioFile=pysox.CSoxStream(audioFileName, 'w', pysox.CSignalInfo(48000,1,32))


class Tee(object):
    def __init__(self, name, mode):
        self.file = open(name, mode)
        self.stdout = sys.stdout
        sys.stdout = self
    def __del__(self):
        sys.stdout = self.stdout
        self.file.close()
    def write(self, data):
        self.file.write(data)
        self.stdout.write(data)
% Parse the file suffix

def main():

if __name__ == "__main__"
    main()
