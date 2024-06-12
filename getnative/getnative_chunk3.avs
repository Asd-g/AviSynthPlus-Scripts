Import("getnative_settings.avs")

chunk = BitShR(max_height - min_height, 2)

min_height = min_height + chunk * 2
max_height = chunk + min_height - 1
getnative_main(log=log, frame=frame, kernel=kernel, b=b, c=c, taps=taps, ar=ar, min_height=min_height, max_height=max_height, stepping=stepping, temp_filename="getnative_3")
