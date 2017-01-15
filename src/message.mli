val read : Lwt_io.input_channel -> bytes Lwt.t

val write : Lwt_io.output_channel -> bytes -> unit Lwt.t
