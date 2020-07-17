## Build HRIR for PulseAudio 7.1 virtual surround from Listen database

# Channel order of the following values
channels={"front_left", "front_center", "front_right", ...
  "side_left", "side_right", "rear_left", "rear_right", "lfe"};
# Azimut angles
azim = [45 0 -45 90 -90 135 -135 180];
# Elevation angles
elev = [0 0 0 0 0 0 0 0];
# Listen database file from
# http://recherche.ircam.fr/equipes/salles/listen/download.html
# It is located at the path "COMPENSATED/MAT/HRIR/" in the zip file.
listen_mat="IRC_1002_C_HRIR.mat"

load(listen_mat);

azim = mod(azim, 360);
indices = (1:1:length(l_eq_hrir_S.elev_v));
max_len=128;
channel_count = length(channels);

for k=1:1:channel_count
  elev_idx = indices(l_eq_hrir_S.elev_v == elev(k));
  azim_idx = indices(l_eq_hrir_S.azim_v == azim(k));
  idx = intersect(azim_idx, elev_idx);
  hrir = l_eq_hrir_S.content_m(idx,1:max_len);

  audiowrite(cstrcat(channels{k}, ".wav"), ...
    hrir, l_eq_hrir_S.sampling_hz);
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
