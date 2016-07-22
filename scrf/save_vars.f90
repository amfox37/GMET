subroutine save_vars (pcp, tmean, trange, nx, ny, grdlat, grdlon, grdalt, times, file, error)
  use netcdf
  use nrtype
  implicit none
!
  real (sp), intent (in) :: pcp (:, :, :), tmean (:, :, :), trange (:, :, :)
  integer (i4b), intent (in) :: nx, ny
  real (dp), intent (in) :: grdlat (:), grdlon (:), grdalt (:)
  real (dp), intent (in) :: times (:)
  character (len=500), intent (in) :: file
  integer, intent (out) :: error
!
!
  ! Dimension names
  character (len=*), parameter :: y_name = "y"
  character (len=*), parameter :: x_name = "x"
  character (len=*), parameter :: time_name = "time"
!
  ! Variable Names
  character (len=*), parameter :: lat_name = "latitude"
  character (len=*), parameter :: lon_name = "longitude"
  character (len=*), parameter :: alt_name = "elevation"
  character (len=*), parameter :: pcp_name = "pcp"
  character (len=*), parameter :: pop_name = "t_mean"
  character (len=*), parameter :: pcp_error_name = "t_range"
!
  character (len=*), parameter :: long_name = "long_name"
  character (len=*), parameter :: pcp_long_name = "estimated precip in mm/day"
  character (len=*), parameter :: pop_long_name = "estimated daily mean temperature"
  character (len=*), parameter :: pcp_error_long_name = "estimated diurnal range"
!
  ! Units
  character (len=*), parameter :: units = "units"
  character (len=*), parameter :: pcp_units = "mm"
  character (len=*), parameter :: pop_units = "deg_C"
  character (len=*), parameter :: pcp_error_units = "deg_C"
  character (len=*), parameter :: lat_units = "degrees_north"
  character (len=*), parameter :: lon_units = "degrees_east"
  character (len=*), parameter :: alt_units = "meters"
  character (len=*), parameter :: time_units = "seconds since 1970-01-01 00:00:00.0 0:00"
  character (len=*), parameter :: fill = "_FillValue"
!
  real (dp), allocatable :: file_times (:)
!
  integer :: n_chars, n_times, inx, iny
  integer :: ncid, x_dimid, y_dimid, time_dimid
  integer :: lat_varid, lon_varid, alt_varid, time_varid, pcp_varid, pop_varid, pcp_error_varid
  integer :: count1 (1), start1 (1), count2 (2), start2 (2), count3 (3), start3 (3), dimids2 (2), &
 & dimids3 (3)
  integer :: trec, nrecs, file_nx, file_ny, file_ntimes, i
!
  trec = 0
  n_chars = 100
  n_times = size (times)
  inx = nx
  iny = ny
!
  if (size(grdlat) /= inx*iny) then
    print *, "Error "
  end if
!
  error = nf90_open (file, nf90_write, ncid)
  if (error /= nf90_noerr) then
    error = 0
     ! Create the file.
    call check (nf90_create(file, nf90_clobber, ncid), "File creation error", error)
    if (error /= 0) return
!
     ! Define the dimensions.
    call check (nf90_def_dim(ncid, y_name, iny, y_dimid), "y dim def error", error)
    call check (nf90_def_dim(ncid, x_name, inx, x_dimid), "x dim def error", error)
    call check (nf90_def_dim(ncid, time_name, nf90_unlimited, time_dimid), "time dim def error", &
   & error)
    if (error /= 0) return
!
     ! Define the variables.
    dimids2 = (/ x_dimid, y_dimid /)
    call check (nf90_def_var(ncid, lat_name, nf90_double, dimids2, lat_varid), "lat var def error", &
   & error)
    call check (nf90_def_var(ncid, lon_name, nf90_double, dimids2, lon_varid), "lon var def error", &
   & error)
    call check (nf90_def_var(ncid, alt_name, nf90_double, dimids2, alt_varid), "lon var def error", &
   & error)
    call check (nf90_def_var(ncid, time_name, nf90_double, time_dimid, time_varid), "time var def e&
   &rror", error)
    if (error /= 0) return
!
    dimids3 = (/ x_dimid, y_dimid, time_dimid /)
    call check (nf90_def_var(ncid, pcp_name, nf90_float, dimids3, pcp_varid), "pcp var def error", &
   & error)
    call check (nf90_def_var(ncid, pop_name, nf90_float, dimids3, pop_varid), "pop var def error", &
   & error)
    call check (nf90_def_var(ncid, pcp_error_name, nf90_float, dimids3, pcp_error_varid), "pcp_erro&
   &r var def error", error)
    if (error /= 0) return
!
    ! Add attributes.
    call check (nf90_put_att(ncid, pcp_varid, long_name, pcp_long_name), "pcp long_name attribute e&
   &rror", error)
    call check (nf90_put_att(ncid, pop_varid, long_name, pop_long_name), "pcp long_name attribute e&
   &rror", error)
    call check (nf90_put_att(ncid, pcp_error_varid, long_name, pcp_error_long_name), "pcp_error lon&
   &g_name attribute error", error)
!
    call check (nf90_put_att(ncid, lat_varid, units, lat_units), "lat units attribute error", &
   & error)
    call check (nf90_put_att(ncid, lon_varid, units, lon_units), "lon units attribute error", &
   & error)
    call check (nf90_put_att(ncid, alt_varid, units, alt_units), "alt units attribute error", &
   & error)
    call check (nf90_put_att(ncid, time_varid, units, time_units), "time units attribute error", &
   & error)
!
    call check (nf90_put_att(ncid, pcp_varid, units, pcp_units), "pcp units attribute error", &
   & error)
    call check (nf90_put_att(ncid, pop_varid, units, pop_units), "pcp units attribute error", &
   & error)
    call check (nf90_put_att(ncid, pcp_error_varid, units, pcp_error_units), "pcp_error units attri&
   &bute error", error)
    if (error /= 0) return
!
     ! End define mode.
    call check (nf90_enddef(ncid), "end define mode error", error)
    if (error /= 0) return
!
    count2 = (/ inx, iny /)
    start2 = (/ 1, 1 /)
!
    call check (nf90_put_var(ncid, lat_varid, grdlat, start=start2, count=count2), "put lat error", &
   & error)
    call check (nf90_put_var(ncid, lon_varid, grdlon, start=start2, count=count2), "put lon error", &
   & error)
    call check (nf90_put_var(ncid, alt_varid, grdalt, start=start2, count=count2), "put alt error", &
   & error)
!
    trec = 1
    nrecs = 0
!
!
  else
!
     ! File already exists, get dim and var ids
    call check (nf90_inq_dimid(ncid, y_name, y_dimid), "y dim inq error", error)
    call check (nf90_inq_dimid(ncid, x_name, x_dimid), "x dim inq error", error)
    call check (nf90_inq_dimid(ncid, time_name, time_dimid), "time dim inq error", error)
    if (error /= 0) return
!
    call check (nf90_inq_varid(ncid, lat_name, lat_varid), "lat var inq error", error)
    call check (nf90_inq_varid(ncid, lon_name, lon_varid), "lon var inq error", error)
    call check (nf90_inq_varid(ncid, time_name, time_varid), "time var inq error", error)
    call check (nf90_inq_varid(ncid, pcp_name, pcp_varid), "pcp var inq error", error)
    call check (nf90_inq_varid(ncid, pop_name, pop_varid), "pop var inq error", error)
    call check (nf90_inq_varid(ncid, pcp_error_name, pcp_error_varid), "pcp_error var inq error", &
   & error)
    if (error /= 0) return
!
    call check (nf90_inquire_dimension(ncid, x_dimid, len=file_nx), "x dim len error", error)
    call check (nf90_inquire_dimension(ncid, y_dimid, len=file_ny), "y dim len error", error)
    call check (nf90_inquire_dimension(ncid, time_dimid, len=file_ntimes), "time dim len error", &
   & error)
    if (error /= 0) return
!
    if (nx /= file_nx .or. ny /= file_ny) then
      print *, "Error dimensions in output file do not match current run."
      error = 1
      return
    end if
!
    allocate (file_times(file_ntimes))
    call check (nf90_get_var(ncid, time_varid, file_times), "error getting file times list", error)
    if (error /= 0) return
!
    if (file_times(1) > times(n_times)) then !put data before everything in the file
      print *, "Error cannot add data before data already in output file. (functionality still to b&
     &e added)"
      error = 1
      return
    else
      if (file_times(file_ntimes) < times(1)) then !put data after everything in the file
        trec = file_ntimes + 1
      else ! at least some overlap
        do i = 1, file_ntimes, 1
          if (file_times(1) == times(1)) then
            trec = i
          end if
        end do
        if (trec == 0) then
          print *, "Error, confusion over data output record location."
          error = 1
          return
        else
          print *, "WARNING, overwriting data in output file, record ", trec, " to ", trec + &
         & n_times - 1
        end if
      end if
    end if
!
  end if
  count1 (1) = n_times
  start1 (1) = trec
  call check (nf90_put_var(ncid, time_varid, times, start=start1, count=count1), "put times error", &
 & error)
  if (error /= 0) return
!
  count3 = (/ inx, iny, n_times /)
  start3 = (/ 1, 1, trec /)
  call check (nf90_put_var(ncid, pcp_varid, pcp, start=start3, count=count3), "put pcp error", &
 & error)
  if (error /= 0) return
!
  call check (nf90_put_var(ncid, pop_varid, tmean, start=start3, count=count3), "put tmean error", &
 & error)
  if (error /= 0) return
  call check (nf90_put_var(ncid, pcp_error_varid, trange, start=start3, count=count3), "put trange &
 &error", error)
  if (error /= 0) return
!
  call check (nf90_close(ncid), "closing file error", error)
!
contains
  subroutine check (status, info, error)
    integer, intent (in) :: status
    character (len=*), intent (in) :: info
    integer, intent (out) :: error
!
    if (status /= nf90_noerr) then
      print *, trim (info) // ": " // trim (nf90_strerror(status))
      error = 1
    end if
  end subroutine check
end subroutine save_vars
