## Build HRIR for PulseAudio 7.1 virtual surround from Listen database

# Channel order of the following values
channels={"front_left", "front_center", "front_right", ...
  "side_left", "side_right", "rear_left", "rear_right", "lfe"};

## Settings
# Azimut angles
azim = [45 0 -45 90 -90 135 -135 180];
# Elevation angles
elev = [0 0 0 0 0 0 0 0];

# Listen database file from
# http://recherche.ircam.fr/equipes/salles/listen/download.html
# It is located at the path "COMPENSATED/MAT/HRIR/" in the zip file.
listen_mat="IRC_1002_C_HRIR.mat"

# Alternatively, HRIRs from
# https://dev.qu.tu-berlin.de/projects/measurements/repository/show/2010-11-kemar-anechoic/mat
# can be used.
#tub_mat="QU_KEMAR_anechoic_1m.mat"

# Apply equalizer to result
equalize_result = false;

# Equalizer settings
eq_freq = [0  30  60 120 250 500 1000 2000 4000 8000 16000 22100];
eq_val  = [1   1   4   1   1   2    3    4    3    2     5     3];

## Processing
function x = load_listen(mat)
  load(mat);
  x.fs = l_eq_hrir_S.sampling_hz;
  x.azim = l_eq_hrir_S.azim_v;
  x.elev = l_eq_hrir_S.elev_v;
  x.data = l_eq_hrir_S.content_m;
end

function x = load_tub(mat)
  load(mat);
  x.fs = irs.fs;
  x.azim = mod(irs.apparent_azimuth/pi*180, 360);
  x.elev = mod(irs.apparent_elevation/pi*180, 360);
  x.data = irs.left.';
end

if exist("listen_mat") == 1
  meas = load_listen(listen_mat);
elseif exist("tub_mat") == 1
  meas = load_tub(tub_mat);
else
  printf("Either listen_mat or tub_mat must be specified\n");
  return
end

azim = mod(azim, 360);
indices = (1:1:length(meas.elev));
max_len=128;
channel_count = length(channels);

eq_tf = interp1(eq_freq, eq_val,
  (1:1:max_len/2)*meas.fs/max_len/2);
eq_ir = real(ifft(cat(2, 0, eq_tf, fliplr(eq_tf(1:length(eq_tf)-1)))));
eq_ir = eq_ir / max(abs(eq_ir));

#plot((1:1:128)*22100/128,eq_tf); hold on; plot(eq_freq, eq_val, 'ro'); hold off

if equalize_result
  hrirs = zeros(channel_count, 2*max_len-1);
else
  hrirs = zeros(channel_count, max_len);
end

for k=1:1:channel_count
  elev_idx = indices(meas.elev == elev(k));
  azim_idx = indices(meas.azim == azim(k));
  idx = intersect(azim_idx, elev_idx);
  hrir = meas.data(idx,1:max_len);
  if equalize_result == true
    hrir = conv(eq_ir, hrir);
  end
  hrirs(k,:) = hrir
end

hrir_max = max(max(abs(hrirs)));

for k=1:1:channel_count
  audiowrite(cstrcat(channels{k}, ".wav"), ...
    hrirs(k,:)/hrir_max, meas.fs);
end

% Assemble it (octave fails channel mapping so use ffmpeg)
system(cstrcat("ffmpeg -y -i front_left.wav -i front_right.wav ",
  "-i front_center.wav -i lfe.wav -i rear_left.wav -i rear_right.wav ",
  "-i side_left.wav -i side_right.wav ",
  "-filter_complex \"[0:a][1:a][2:a][3:a][4:a][5:a][6:a][7:a]",
  "amerge=inputs=8[a]\" -map \"[a]\" hrir.wav"));

for k=1:1:channel_count
  unlink(cstrcat(channels{k}, ".wav"));
end
