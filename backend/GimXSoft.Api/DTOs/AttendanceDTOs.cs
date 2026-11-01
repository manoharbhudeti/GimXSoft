using System.ComponentModel.DataAnnotations;
using GimXSoft.Api.Entities;

namespace GimXSoft.Api.DTOs;

public record AttendanceRecordDto(
    Guid Id,
    Guid TenantId,
    Guid BranchId,
    string? BranchName,
    Guid MemberId,
    string MemberName,
    string MemberCode,
    string? PlanName,
    DateTime CheckInTime,
    DateTime? CheckOutTime,
    string Method,
    string? Notes
);

public record CheckInRequest(
    Guid BranchId,
    [Required] string MemberCodeOrId,
    AttendanceMethod Method = AttendanceMethod.Manual,
    string? Notes = null
);

public record CheckOutRequest(
    Guid AttendanceId,
    string? Notes = null
);

public record DailyAttendanceSummaryDto(
    int TotalCheckInsToday,
    int CurrentlyInGym,
    int MorningPeakCount,
    int EveningPeakCount,
    List<AttendanceRecordDto> RecentCheckIns
);

