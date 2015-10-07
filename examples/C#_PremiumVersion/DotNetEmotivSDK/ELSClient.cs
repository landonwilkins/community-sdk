using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace Emotiv
{
    public class ELSClient
    {
        public enum profileFileType
	    {
		    TRAINING,
		    EMOKEY
	    };

        public struct profileVersionInfo
	    {
		    public int version;
		    public IntPtr last_modified;
	    };

        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_Connect")]
        public static extern bool ELS_Connect();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_Login")]
        public static extern bool ELS_Login(String email, String password, ref int userID);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_CreateHeadset")]
        public static extern bool ELS_CreateHeadset(int userID);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_CreateProtocol")]
        public static extern bool ELS_CreateProtocol(String name, ref int protocolID);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_AddSubjectToProtocol")]
        public static extern bool ELS_AddSubjectToProtocol(int userID, int protocolID);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_SetProtocol")]
        public static extern bool ELS_SetProtocol(int protocolID);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_SetExperiment")]
        public static extern bool ELS_SetExperiment(int experimentID);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_CreateExperiment")]
        public static extern bool ELS_CreateExperiment(String name, String description, ref int experimentID);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_CreateRecordingSession")]
        public static extern IntPtr ELS_CreateRecordingSession();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_StartRecordData")]
        public static extern bool ELS_StartRecordData();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_StartRecordDataWithOCEFile")]
        public static extern bool ELS_StartRecordDataWithOCEFile(String oceiFilePath, ref bool overtime, int timeLimit = 24);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_StopRecordData")]
        public static extern bool ELS_StopRecordData();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_GetReportOnline")]
        public static extern void ELS_GetReportOnline(ref int engagementScore, ref int excitementScore, ref int stressScore, ref int relaxScore, ref int interestScore);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_GetOfflineReport")]
        public static extern void ELS_GetOfflineReport(ref int engagementScore, ref int excitementScore, ref int affinityScore);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_Marker_EyeOpenStart")]
        public static extern bool ELS_Marker_EyeOpenStart();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_Marker_EyeOpenEnd")]
        public static extern bool ELS_Marker_EyeOpenEnd();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_Marker_EyeClosedStart")]
        public static extern bool ELS_Marker_EyeClosedStart();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_Marker_EyeClosedEnd")]
        public static extern bool ELS_Marker_EyeClosedEnd();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_Marker_RecordingStart")]
        public static extern bool ELS_Marker_RecordingStart();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_UpdateNote")]
        public static extern bool ELS_UpdateNote(String note);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_UpdateTag")]
        public static extern bool ELS_UpdateTag(String[] tag);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_UploadPhoto")]
        public static extern bool ELS_UploadPhoto(String filePath);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_Disconnect")]
        public static extern void ELS_Disconnect();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_UploadEdfFile")]
        public static extern String ELS_UploadEdfFile(String emostateFilePath, String edfFilePath);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_UploadProfileFile")]
        public static extern bool ELS_UploadProfileFile(String profileName, String filePath, profileFileType ptype);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_UpdateProfileFile")]
        public static extern bool ELS_UpdateProfileFile(int profileId, String filePath);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_DeleteProfileFile")]
        public static extern bool ELS_DeleteProfileFile(int profileId);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_GetProfileId")]
        public static extern int ELS_GetProfileId(String profileName);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_DownloadFileProfile")]
        public static extern bool ELS_DownloadFileProfile(int profileId,String destPath,int version);  //default = -1 for download lastest version
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_GetAllProfileName")]
        public static extern int ELS_GetAllProfileName();
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_ProfileIDAtIndex")]
        public static extern int ELS_ProfileIDAtIndex(int index);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_ProfileNameAtIndex")]
        public static extern String ELS_ProfileNameAtIndex(int index);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_ProfileLastModifiedAtIndex")]
        public static extern IntPtr ELS_ProfileLastModifiedAtIndex(int index);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_ProfileTypeAtIndex")]
        public static extern profileFileType ELS_ProfileTypeAtIndex(int index);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_SaveOpenCloseEyeInfo")]
        public static extern bool ELS_SaveOpenCloseEyeInfo(String fileName);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_ResetPassword")]
        public static extern bool ELS_ResetPassword(String userName);
        
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_Logout")]
        public static extern bool ELS_Logout();

        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_SetDefaultUser")]
        public static extern bool ELS_SetDefaultUser(int userID);

        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_GetDefaultUser")]
        public static extern int ELS_GetDefaultUser();

        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_GetAvailableProfileVersions")]
        public static extern bool ELS_GetAvailableProfileVersions(int profileID, out profileVersionInfo pVersionInfo, ref int nVersion);
     
        [DllImport("edk.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ELS_SetClientSecret")]
        public static extern void ELS_SetClientSecret(String profileID, String clientSecret);
    }
}
