using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace Emotiv
{
    /// <summary>
    /// Exception class for EmoEngine
    /// </summary>
    public class EmoEngineException : System.ApplicationException
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public EmoEngineException() : base() { }
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="message">Error message</param>
        public EmoEngineException(string message) : base(message) { }
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="message">Error message</param>
        /// <param name="inner"></param>
        public EmoEngineException(string message, System.Exception inner) : base(message, inner) { }
        /// <summary>
        /// Constructor needed for serialization when exception propagates from a remoting server to the client.
        /// </summary>
        /// <param name="info"></param>
        /// <param name="context"></param>
        protected EmoEngineException(System.Runtime.Serialization.SerializationInfo info,
            System.Runtime.Serialization.StreamingContext context) : base(info, context) { }
 
        private Int32 errorCode = 0;

        /// <summary>
        /// Error code defined in edk.h returned directly from the unmanaged APIs in edk.dll
        /// </summary> 
        public Int32 ErrorCode
        {
            get
            {
                return errorCode;
            }
            set
            {
                errorCode = value;
            }
        }
    }

    /// <summary>
    /// Class to hold metadata of EmoEngine event 
    /// </summary> 
    public class EmoEngineEventArgs : EventArgs
    {
        /// <summary>
        /// User ID
        /// </summary>
        public UInt32 userId;

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="userId">User ID</param>
        public EmoEngineEventArgs(UInt32 userId)
        {
            this.userId= userId;
        }
    }

    /// <summary>
    /// Class to hold metadata of EmoStateUpdated event
    /// </summary> 
    public class EmoStateUpdatedEventArgs : EmoEngineEventArgs
    {
        /// <summary>
        /// EmoState
        /// </summary>
        public EmoState emoState;
        
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="emoState">EmoState</param>
        public EmoStateUpdatedEventArgs(UInt32 userId, EmoState emoState) : base(userId)
        {
            this.emoState = emoState;
        }
    }

    /// <summary>
    /// Provide APIs to communicate with EmoEngine 
    /// </summary>
    public class EmoEngine
    {
        private static EmoEngine instance;
        private Dictionary<UInt32, EmoState> lastEmoState = new Dictionary<UInt32, EmoState>();
        private IntPtr hEvent;

        private IntPtr hMotionData;
        
        /// <summary>
        /// Function pointer of callback functions which will be called when EmoEngineConnectedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void EmoEngineConnectedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when EmoEngineDisconnectedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void EmoEngineDisconnectedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when UserAddedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void UserAddedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when UserRemovedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void UserRemovedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when ProfileEventEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void ProfileEventEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandTrainingStartedEventEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandTrainingStartedEventEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandTrainingSucceededEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandTrainingSucceededEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandTrainingFailedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandTrainingFailedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandTrainingCompletedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandTrainingCompletedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandTrainingDataErasedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandTrainingDataErasedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandTrainingRejectedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandTrainingRejectedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandTrainingResetEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandTrainingResetEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandAutoSamplingNeutralCompletedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandAutoSamplingNeutralCompletedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandSignatureUpdatedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandSignatureUpdatedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when FacialExpressionTrainingStartedEventEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>

        public delegate void FacialExpressionTrainingStartedEventEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when FacialExpressionTrainingSucceededEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void FacialExpressionTrainingSucceededEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when FacialExpressionTrainingFailedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void FacialExpressionTrainingFailedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when FacialExpressionTrainingCompletedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void FacialExpressionTrainingCompletedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when FacialExpressionTrainingDataErasedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void FacialExpressionTrainingDataErasedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when FacialExpressionTrainingRejectedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void FacialExpressionTrainingRejectedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when FacialExpressionTrainingResetEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void FacialExpressionTrainingResetEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when InternalStateChangedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void InternalStateChangedEventHandler(object sender, EmoEngineEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when EmoStateUpdatedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void EmoStateUpdatedEventHandler(object sender, EmoStateUpdatedEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when EmoEngineEmoStateUpdatedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void EmoEngineEmoStateUpdatedEventHandler(object sender, EmoStateUpdatedEventArgs e);
        
        /// <summary>
        /// Function pointer of callback functions which will be called when FacialExpressionEmoStateUpdatedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void FacialExpressionEmoStateUpdatedEventHandler(object sender, EmoStateUpdatedEventArgs e);
        /// <summary>
        /// Function pointer of callback functions which will be called when MentalCommandEmoStateUpdatedEvent occurs
        /// </summary>
        /// <param name="sender">Object which triggers the event</param>
        /// <param name="e">Contains metadata of the event</param>
        public delegate void MentalCommandEmoStateUpdatedEventHandler(object sender, EmoStateUpdatedEventArgs e);
        
        /// <summary>
        /// Raise when EmoEngine is successfully connected
        /// </summary>
        public event EmoEngineConnectedEventHandler EmoEngineConnected;
        
        /// <summary>
        /// Raise when EmoEngine is disconnected
        /// </summary>
        public event EmoEngineDisconnectedEventHandler EmoEngineDisconnected;

        /// <summary>
        /// Raise when a new user is added or when the dongle is plugged in
        /// </summary>
        public event UserAddedEventHandler UserAdded;
        /// <summary>
        /// Raise when a user is removed or when the dongle is removed
        /// </summary>
        public event UserRemovedEventHandler UserRemoved;        

        /// <summary>
        /// Raise when cognitv training is stareted
        /// </summary>
        public event MentalCommandTrainingStartedEventEventHandler MentalCommandTrainingStarted;
        /// <summary>
        /// Raise when MentalCommand training is completed and the training data is in good quality but the signature has not been updated yet.
        /// EmoEngine awaits the accept or reject training control signal after the event is raised.
        /// Once the control signal is received, EmoEngine will update signature for MentalCommand correspondingly.
        /// </summary>
        public event MentalCommandTrainingSucceededEventHandler MentalCommandTrainingSucceeded;
        /// <summary>
        /// Raise when MentalCommand training is completed but the signal during training is too noisy to be used for building MentalCommand signature.
        /// </summary>
        public event MentalCommandTrainingFailedEventHandler MentalCommandTrainingFailed;
        /// <summary>
        /// Raise when the signature has successfully been updated after the accept training control is received.
        /// </summary>
        public event MentalCommandTrainingCompletedEventHandler MentalCommandTrainingCompleted;
        /// <summary>
        /// Raise when MentalCommand training data is erased
        /// </summary>
        public event MentalCommandTrainingDataErasedEventHandler MentalCommandTrainingDataErased;
        /// <summary>
        /// Raise when the reject training control is received
        /// </summary>
        public event MentalCommandTrainingRejectedEventHandler MentalCommandTrainingRejected;
        /// <summary>
        /// Raise when the MentalCommand algorithm is reset.
        /// </summary>
        public event MentalCommandTrainingResetEventHandler MentalCommandTrainingReset;
        /// <summary>
        /// Raise when auto sampling neutral is completed
        /// </summary>
        public event MentalCommandAutoSamplingNeutralCompletedEventHandler MentalCommandAutoSamplingNeutralCompleted;
        /// <summary>
        /// Raise when signature is updated after active actions are updated
        /// </summary>
        public event MentalCommandSignatureUpdatedEventHandler MentalCommandSignatureUpdated;
        /// <summary>
        /// Raise when FacialExpression training is started
        /// </summary>
        public event FacialExpressionTrainingStartedEventEventHandler FacialExpressionTrainingStarted;
        /// <summary>
        /// Raise when FacialExpression training is completed and the training data is in good quality but the signature has not been updated yet.
        /// EmoEngine awaits the accept or reject training control signal after the event is raised.
        /// Once the control signal is received, EmoEngine will update signature for FacialExpression correspondingly.
        /// </summary>
        public event FacialExpressionTrainingSucceededEventHandler FacialExpressionTrainingSucceeded;
        /// <summary>
        /// Raise when MentalCommand training is completed but the signal during training is too noisy to be used for building MentalCommand signature.
        /// </summary>
        public event FacialExpressionTrainingFailedEventHandler FacialExpressionTrainingFailed;
        /// <summary>
        /// Raise when the signature has successfully been updated after the accept training control is received.
        /// </summary>
        public event FacialExpressionTrainingCompletedEventHandler FacialExpressionTrainingCompleted;
        /// <summary>
        /// Raise when FacialExpression training data is erased
        /// </summary>
        public event FacialExpressionTrainingDataErasedEventHandler FacialExpressionTrainingDataErased;
        /// <summary>
        /// Raise when the reject training control is received
        /// </summary>
        public event FacialExpressionTrainingRejectedEventHandler FacialExpressionTrainingRejected;
        /// <summary>
        /// Raise when the FacialExpression algorithm is reset.
        /// </summary>
        public event FacialExpressionTrainingResetEventHandler FacialExpressionTrainingReset;
        /// <summary>
        /// Raise when EmoEngine is connected to Control Panel in proxy mode and 
        /// user has updated the internal state of EmoEngine with the Control Panel UI,
        /// such as changing the sensitivity of an expression or updating the optimization setting
        /// </summary>
        public event InternalStateChangedEventHandler InternalStateChanged;
        /// <summary>
        /// Raise when EmoState is updated
        /// </summary>
        public event EmoStateUpdatedEventHandler EmoStateUpdated;
        /// <summary>
        /// Raise when EmoEngine related EmoState is updated
        /// </summary>
        public event EmoEngineEmoStateUpdatedEventHandler EmoEngineEmoStateUpdated;
        
        /// <summary>
        /// Raise when FacialExpression related EmoState is updated
        /// </summary>
        public event FacialExpressionEmoStateUpdatedEventHandler FacialExpressionEmoStateUpdated;
        /// <summary>
        /// Raise when MentalCommand related EmoState is updated
        /// </summary>
        public event MentalCommandEmoStateUpdatedEventHandler MentalCommandEmoStateUpdated;

        private EmoEngine() 
        {
            hEvent = EdkDll.IEE_EmoEngineEventCreate();
            hMotionData = EdkDll.IEE_MotionDataCreate();
        }

        /// <summary>
        /// Destructor of EmoEngine
        /// </summary>
        ~EmoEngine()
        {
            if (hEvent != IntPtr.Zero) EdkDll.IEE_EmoEngineEventFree(hEvent);
            if (hMotionData != IntPtr.Zero) EdkDll.IEE_MotionDataFree(hMotionData);
        }

        /// <summary>
        /// Global instance of EmoEngine
        /// </summary>
        public static EmoEngine Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new EmoEngine();
                }
                return instance;
            }
        }
        /// <summary>
        /// Processes EmoEngine events until there is no more events
        /// </summary>
        public void ProcessEvents()
        {
            ProcessEvents(0);
        }
        /// <summary>
        /// Processes EmoEngine events until there is no more events or maximum processing time has elapsed
        /// </summary>
        /// <param name="maxTimeMilliseconds">maximum processing time in milliseconds</param>
        public void ProcessEvents(Int32 maxTimeMilliseconds)
        {
            Stopwatch st = new Stopwatch();

            st.Start();
            while (EdkDll.IEE_EngineGetNextEvent(hEvent) == EdkDll.EDK_OK)
            {
                if (maxTimeMilliseconds != 0)
                {
                    if (st.ElapsedMilliseconds >= maxTimeMilliseconds)
                        break;
                }
                UInt32 userId = 0;
                EdkDll.IEE_EmoEngineEventGetUserId(hEvent, out userId);
                EmoEngineEventArgs args = new EmoEngineEventArgs(userId);
                EdkDll.IEE_Event_t eventType = EdkDll.IEE_EmoEngineEventGetType(hEvent);
                switch (eventType)
                {
                    case EdkDll.IEE_Event_t.IEE_UserAdded:
                        OnUserAdded(args);
                        break;
                    case EdkDll.IEE_Event_t.IEE_UserRemoved:
                        OnUserRemoved(args);
                        break;
                    case EdkDll.IEE_Event_t.IEE_EmoStateUpdated:
                        EmoState curEmoState = new EmoState();
                        errorHandler(EdkDll.IEE_EmoEngineEventGetEmoState(hEvent, curEmoState.GetHandle()));
                        EmoStateUpdatedEventArgs emoStateUpdatedEventArgs = new EmoStateUpdatedEventArgs(userId, curEmoState);
                        OnEmoStateUpdated(emoStateUpdatedEventArgs);
                        if (!curEmoState.EmoEngineEqual(lastEmoState[userId]))
                        {
                            emoStateUpdatedEventArgs = new EmoStateUpdatedEventArgs(userId, new EmoState(curEmoState));
                            OnEmoEngineEmoStateUpdated(emoStateUpdatedEventArgs);  
                        }
                        if (!curEmoState.MentalCommandEqual(lastEmoState[userId]))
                        {
                            emoStateUpdatedEventArgs = new EmoStateUpdatedEventArgs(userId, new EmoState(curEmoState));
                            OnMentalCommandEmoStateUpdated(emoStateUpdatedEventArgs);
                        }
                        if (!curEmoState.FacialExpressionEqual(lastEmoState[userId]))
                        {
                            emoStateUpdatedEventArgs = new EmoStateUpdatedEventArgs(userId, new EmoState(curEmoState));
                            OnFacialExpressionEmoStateUpdated(emoStateUpdatedEventArgs);
                        }
                        lastEmoState[userId] = (EmoState)curEmoState.Clone();
                        break;     
                    case EdkDll.IEE_Event_t.IEE_MentalCommandEvent: 
                        EdkDll.IEE_MentalCommandEvent_t cogType = EdkDll.IEE_MentalCommandEventGetType(hEvent);
                        switch(cogType){
                            case EdkDll.IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingStarted:
                                OnMentalCommandTrainingStarted(args);
                                break;
                            case EdkDll.IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingSucceeded:
                                OnMentalCommandTrainingSucceeded(args);
                                break;
                            case EdkDll.IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingFailed:
                                OnMentalCommandTrainingFailed(args);
                                break;
                            case EdkDll.IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingCompleted:
                                OnMentalCommandTrainingCompleted(args);
                                break;
                            case EdkDll.IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingDataErased:
                                OnMentalCommandTrainingDataErased(args);
                                break;
                            case EdkDll.IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingRejected:
                                OnMentalCommandTrainingRejected(args);
                                break;
                            case EdkDll.IEE_MentalCommandEvent_t.IEE_MentalCommandTrainingReset:
                                OnMentalCommandTrainingReset(args);
                                break;
                            case EdkDll.IEE_MentalCommandEvent_t.IEE_MentalCommandAutoSamplingNeutralCompleted:
                                OnMentalCommandAutoSamplingNeutralCompleted(args);
                                break;
                            case EdkDll.IEE_MentalCommandEvent_t.IEE_MentalCommandSignatureUpdated:
                                OnMentalCommandSignatureUpdated(args);
                                break;
                            default:
                                break;
                        }
                        break;
                    case EdkDll.IEE_Event_t.IEE_FacialExpressionEvent:
                        EdkDll.IEE_FacialExpressionEvent_t expEvent = EdkDll.IEE_FacialExpressionEventGetType(hEvent);
                        switch (expEvent)
                        {
                            case EdkDll.IEE_FacialExpressionEvent_t.IEE_FacialExpressionTrainingStarted:
                                OnFacialExpressionTrainingStarted(args);
                                break;
                            case EdkDll.IEE_FacialExpressionEvent_t.IEE_FacialExpressionTrainingSucceeded:
                                OnFacialExpressionTrainingSucceeded(args);
                                break;
                            case EdkDll.IEE_FacialExpressionEvent_t.IEE_FacialExpressionTrainingFailed:
                                OnFacialExpressionTrainingFailed(args);
                                break;
                            case EdkDll.IEE_FacialExpressionEvent_t.IEE_FacialExpressionTrainingCompleted:
                                OnFacialExpressionTrainingCompleted(args);
                                break;
                            case EdkDll.IEE_FacialExpressionEvent_t.IEE_FacialExpressionTrainingDataErased:
                                OnFacialExpressionTrainingDataErased(args);
                                break;
                            case EdkDll.IEE_FacialExpressionEvent_t.IEE_FacialExpressionTrainingRejected:
                                OnFacialExpressionTrainingRejected(args);
                                break;
                            case EdkDll.IEE_FacialExpressionEvent_t.IEE_FacialExpressionTrainingReset:
                                OnFacialExpressionTrainingReset(args);
                                break;                            
                            default:
                                break;
                        }
                        break;
                    case EdkDll.IEE_Event_t.IEE_InternalStateChanged:
                        OnInternalStateChanged(args);
                        break;
                    default:
                        break;
                }
            }
        }
        
        /// <summary>
        /// Handler for EmoEngineConnected event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnEmoEngineConnected(EmoEngineEventArgs e)
        {
            lastEmoState.Clear();
            if (EmoEngineConnected != null)
                EmoEngineConnected(this, e);
        }

        /// <summary>
        /// Handler for EmoEngineDisconnected event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnEmoEngineDisconnected(EmoEngineEventArgs e)
        {            
            if (EmoEngineDisconnected != null)
                EmoEngineDisconnected(this, e);
        }

        /// <summary>
        /// Handler for UserAdded event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnUserAdded(EmoEngineEventArgs e)
        {
            lastEmoState.Add(e.userId, new EmoState());
            if (UserAdded != null)
                UserAdded(this, e);
        }

        /// <summary>
        /// Handler for UserRemoved event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnUserRemoved(EmoEngineEventArgs e)
        {
            lastEmoState.Remove(e.userId);
            if (UserRemoved != null)
                UserRemoved(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandTrainingStarted event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandTrainingStarted(EmoEngineEventArgs e)
        {
            if (MentalCommandTrainingStarted != null)
                MentalCommandTrainingStarted(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandTrainingSucceeded event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandTrainingSucceeded(EmoEngineEventArgs e)
        {
            if (MentalCommandTrainingSucceeded != null)
                MentalCommandTrainingSucceeded(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandTrainingFailed event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandTrainingFailed(EmoEngineEventArgs e)
        {
            if (MentalCommandTrainingFailed != null)
                MentalCommandTrainingFailed(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandTrainingCompleted event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandTrainingCompleted(EmoEngineEventArgs e)
        {
            if (MentalCommandTrainingCompleted != null)
                MentalCommandTrainingCompleted(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandTrainingDataErased event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandTrainingDataErased(EmoEngineEventArgs e)
        {
            if (MentalCommandTrainingDataErased != null)
                MentalCommandTrainingDataErased(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandTrainingRejected event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandTrainingRejected(EmoEngineEventArgs e)
        {
            if (MentalCommandTrainingRejected != null)
                MentalCommandTrainingRejected(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandTrainingReset event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandTrainingReset(EmoEngineEventArgs e)
        {
            if (MentalCommandTrainingReset != null)
                MentalCommandTrainingReset(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandAutoSamplingNeutralCompleted event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandAutoSamplingNeutralCompleted(EmoEngineEventArgs e)
        {
            if (MentalCommandAutoSamplingNeutralCompleted != null)
                MentalCommandAutoSamplingNeutralCompleted(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandSignatureUpdated event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandSignatureUpdated(EmoEngineEventArgs e)
        {
            if (MentalCommandSignatureUpdated != null)
                MentalCommandSignatureUpdated(this, e);
        }

        /// <summary>
        /// Handler for FacialExpressionTrainingStarted event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnFacialExpressionTrainingStarted(EmoEngineEventArgs e)
        {
            if (FacialExpressionTrainingStarted != null)
                FacialExpressionTrainingStarted(this, e);
        }

        /// <summary>
        /// Handler for FacialExpressionTrainingSucceeded event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnFacialExpressionTrainingSucceeded(EmoEngineEventArgs e)
        {
            if (FacialExpressionTrainingSucceeded != null)
                FacialExpressionTrainingSucceeded(this, e);
        }

        /// <summary>
        /// Handler for FacialExpressionTrainingFailed event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnFacialExpressionTrainingFailed(EmoEngineEventArgs e)
        {
            if (FacialExpressionTrainingFailed != null)
                FacialExpressionTrainingFailed(this, e);
        }

        /// <summary>
        /// Handler for FacialExpressionTrainingCompleted event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnFacialExpressionTrainingCompleted(EmoEngineEventArgs e)
        {
            if (FacialExpressionTrainingCompleted != null)
                FacialExpressionTrainingCompleted(this, e);
        }

        /// <summary>
        /// Handler for FacialExpressionTrainingDataErased event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnFacialExpressionTrainingDataErased(EmoEngineEventArgs e)
        {
            if (FacialExpressionTrainingDataErased != null)
                FacialExpressionTrainingDataErased(this, e);
        }

        /// <summary>
        /// Handler for FacialExpressionTrainingRejected event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnFacialExpressionTrainingRejected(EmoEngineEventArgs e)
        {
            if (FacialExpressionTrainingRejected != null)
                FacialExpressionTrainingRejected(this, e);
        }

        /// <summary>
        /// Handler for FacialExpressionTrainingReset event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnFacialExpressionTrainingReset(EmoEngineEventArgs e)
        {
            if (FacialExpressionTrainingReset != null)
                FacialExpressionTrainingReset(this, e);
        }

        /// <summary>
        /// Handler for InternalStateChanged event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnInternalStateChanged(EmoEngineEventArgs e)
        {
            if (InternalStateChanged != null)
                InternalStateChanged(this, e);
        }

        /// <summary>
        /// Handler for EmoStateUpdated event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnEmoStateUpdated(EmoStateUpdatedEventArgs e)
        {
            if (EmoStateUpdated != null)
                EmoStateUpdated(this, e);
        }

        /// <summary>
        /// Handler for EmoEngineEmoStateUpdated event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnEmoEngineEmoStateUpdated(EmoStateUpdatedEventArgs e)
        {
            if (EmoEngineEmoStateUpdated != null)
                EmoEngineEmoStateUpdated(this, e);
        }


        /// <summary>
        /// Handler for FacialExpressionEmoStateUpdated event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnFacialExpressionEmoStateUpdated(EmoStateUpdatedEventArgs e)
        {
            if (FacialExpressionEmoStateUpdated != null)
                FacialExpressionEmoStateUpdated(this, e);
        }

        /// <summary>
        /// Handler for MentalCommandEmoStateUpdated event
        /// </summary>
        /// <param name="e">Contains metadata of the event, like userID</param>
        protected virtual void OnMentalCommandEmoStateUpdated(EmoStateUpdatedEventArgs e)
        {
            if (MentalCommandEmoStateUpdated != null)
                MentalCommandEmoStateUpdated(this, e);
        }

        /// <summary>
        /// Generates EmoEngineException
        /// </summary>
        /// <param name="errorCode">error code returned from APIs from edk.dll</param>
        public static void errorHandler(Int32 errorCode)
        {
            if (errorCode == EdkDll.EDK_OK)
                return;

            string errorStr = "";
            switch (errorCode)
            {
                case EdkDll.EDK_INVALID_PROFILE_ARCHIVE:
                    errorStr = "Invalid profile archive";
                    break;
                case EdkDll.EDK_NO_USER_FOR_BASEPROFILE:
                    errorStr = "The base profile does not have a user ID";
                    break;
                case EdkDll.EDK_CANNOT_ACQUIRE_DATA:
                    errorStr = "EmoEngine is unable to acquire EEG input data";
                    break;
                case EdkDll.EDK_BUFFER_TOO_SMALL:
                    errorStr = "A supplied buffer is not large enough";
                    break;
                case EdkDll.EDK_OUT_OF_RANGE:
                    errorStr = "Parameter is out of range";
                    break;
                case EdkDll.EDK_INVALID_PARAMETER:
                    errorStr = "Parameter is invalid";
                    break;
                case EdkDll.EDK_PARAMETER_LOCKED:
                    errorStr = "Parameter is locked";
                    break;
                case EdkDll.EDK_INVALID_USER_ID:
                    errorStr = "User ID supplied to the function is invalid";
                    break;
                case EdkDll.EDK_EMOENGINE_UNINITIALIZED:
                    errorStr = "EmoEngine has not been initialized";
                    break;
                case EdkDll.EDK_EMOENGINE_DISCONNECTED:
                    errorStr = "Connection with remote instance of EmoEngine has been lost";
                    break;
                case EdkDll.EDK_EMOENGINE_PROXY_ERROR:
                    errorStr = "Unable to establish connection with remote instance of EmoEngine.";
                    break;
                case EdkDll.EDK_NO_EVENT:
                    errorStr = "There are no new EmoEngine events at this time.";
                    break;
                case EdkDll.EDK_GYRO_NOT_CALIBRATED:
                    errorStr = "The gyro could not be calibrated.  The headset must remain still for at least 0.5 secs.";
                    break;
                case EdkDll.EDK_OPTIMIZATION_IS_ON:
                    errorStr = "The requested operation failed due to optimization settings.";
                    break;
                case EdkDll.EDK_UNKNOWN_ERROR:
                    errorStr = "Unknown error";
                    break;
                default:
                    errorStr = "Unknown error";
                    break;
            }

            EmoEngineException exception = new EmoEngineException(errorStr);
            exception.ErrorCode = errorCode;
            throw exception;
        }

        /// <summary>
        /// Initializes the connection to EmoEngine. This function should be called at the beginning of programs that make use of EmoEngine, most probably in initialization routine or constructor.
        /// </summary>       
        public void Connect()
        {
            errorHandler(EdkDll.IEE_EngineConnect("Emotiv Systems-5"));
            OnEmoEngineConnected(new EmoEngineEventArgs(UInt32.MaxValue));
        }


        /// <summary>
        /// Initializes the connection to a remote instance of EmoEngine.
        /// </summary>
        /// <param name="ip">A string identifying the hostname or IP address of the remote EmoEngine server</param>
        /// <param name="port">The port number of the remote EmoEngine server. If connecting to the Emotiv Control Panel, use port 3008. If connecting to the EmoComposer, use port 1726</param>
        public void RemoteConnect(String ip, UInt16 port)
        {
            errorHandler(EdkDll.IEE_EngineRemoteConnect(ip, port));
            OnEmoEngineConnected(new EmoEngineEventArgs(UInt32.MaxValue));
        }

        /// <summary>
        /// Terminates the connection to EmoEngine. This function should be called at the end of programs which make use of EmoEngine, most probably in clean up routine or destructor.
        /// </summary>
        public void Disconnect()
        {
            errorHandler(EdkDll.IEE_EngineDisconnect());
            OnEmoEngineDisconnected(new EmoEngineEventArgs(UInt32.MaxValue));
        }

        /// <summary>
        /// Retrieves number of active users connected to the EmoEngine.
        /// </summary>
        /// <returns></returns>
        public UInt32 EngineGetNumUser()
        {
            UInt32 numUser = 0;
            errorHandler(EdkDll.IEE_EngineGetNumUser(out numUser));
            return numUser;
        }

        /// <summary>
        /// Sets the player number displayed on the physical input device (currently the USB Dongle) that corresponds to the specified user
        /// </summary>
        /// <param name="userId">EmoEngine user ID</param>
        /// <param name="playerNum">application assigned player number displayed on input device hardware (must be in the range 1-4)</param>
        public void SetHardwarePlayerDisplay(UInt32 userId, UInt32 playerNum)
        {
            errorHandler(EdkDll.IEE_SetHardwarePlayerDisplay(userId, playerNum));
        }

        /// <summary>
        /// Set threshold for FacialExpression algorithms
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="algoName">FacialExpression algorithm type</param>
        /// <param name="thresholdName">FacialExpression threshold type</param>
        /// <param name="value">threshold value (min: 0 max: 1000)</param>
        public void FacialExpressionSetThreshold(UInt32 userId, EdkDll.IEE_FacialExpressionAlgo_t algoName, EdkDll.IEE_FacialExpressionThreshold_t thresholdName, Int32 value)
        {
            errorHandler(EdkDll.IEE_FacialExpressionSetThreshold(userId, algoName, thresholdName, value));
        }

        /// <summary>
        /// Get threshold from FacialExpression algorithms
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="algoName">FacialExpression algorithm type</param>
        /// <param name="thresholdName">FacialExpression threshold type</param>
        /// <returns>receives threshold value</returns>
        public Int32 FacialExpressionGetThreshold(UInt32 userId, EdkDll.IEE_FacialExpressionAlgo_t algoName, EdkDll.IEE_FacialExpressionThreshold_t thresholdName)
        {
            Int32 valueOut = 0;
            errorHandler(EdkDll.IEE_FacialExpressionGetThreshold(userId, algoName, thresholdName, out valueOut));
            return valueOut;
        }

        /// <summary>
        /// Set the current facial expression for FacialExpression training
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="action">which facial expression would like to be trained</param>
        public void FacialExpressionSetTrainingAction(UInt32 userId, EdkDll.IEE_FacialExpressionAlgo_t action)
        {
            errorHandler(EdkDll.IEE_FacialExpressionSetTrainingAction(userId, action));
        }

        /// <summary>
        /// Set the control flag for FacialExpression training
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="control">pre-defined control command</param>
        public void FacialExpressionSetTrainingControl(UInt32 userId, EdkDll.IEE_FacialExpressionTrainingControl_t control)
        {
            errorHandler(EdkDll.IEE_FacialExpressionSetTrainingControl(userId, control));
        }

        /// <summary>
        /// Gets the facial expression currently selected for FacialExpression training
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>receives facial expression currently selected for training</returns>
        public EdkDll.IEE_FacialExpressionAlgo_t FacialExpressionGetTrainingAction(UInt32 userId)
        {
            EdkDll.IEE_FacialExpressionAlgo_t actionOut;
            errorHandler(EdkDll.IEE_FacialExpressionGetTrainingAction(userId, out actionOut));
            return actionOut;
        }

        /// <summary>
        /// Return the duration of a FacialExpression training session
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>receive the training time in ms</returns>
        public UInt32 FacialExpressionGetTrainingTime(UInt32 userId)
        {
            UInt32 trainingTimeOut = 0;
            errorHandler(EdkDll.IEE_FacialExpressionGetTrainingTime(userId, out trainingTimeOut));
            return trainingTimeOut;
        }

        /// <summary>
        /// Gets a list of the actions that have been trained by the user
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>receives a bit vector composed of IEE_FacialExpressionAlgo_t contants</returns>
        public UInt32 FacialExpressionGetTrainedSignatureActions(UInt32 userId)
        {
            UInt32 trainedActionsOut = 0;
            errorHandler(EdkDll.IEE_FacialExpressionGetTrainedSignatureActions(userId, out trainedActionsOut));
            return trainedActionsOut;
        }

        /// <summary>
        /// Gets a flag indicating if the user has trained sufficient actions to activate a trained signature
        /// </summary>        
        /// <param name="userId">user ID</param>
        /// <returns>1 if the user has trained EXP_NEUTRAL and at least one other FacialExpression action. Otherwise, 0 is returned.</returns>
        public Int32 FacialExpressionGetTrainedSignatureAvailable(UInt32 userId)
        {
            Int32 availableOut = 0;
            errorHandler(EdkDll.IEE_FacialExpressionGetTrainedSignatureAvailable(userId, out availableOut));
            return availableOut;
        }

        /// <summary>
        /// Configures the FacialExpression suite to use either the built-in, universal signature or a personal, trained signature
        /// </summary>
        /// <remarks>
        /// FacialExpression defaults to use its universal signature.  This function will fail if IEE_FacialExpressionGetTrainedSignatureAvailable returns false.
        /// </remarks>
        /// <param name="userId">user ID</param>
        /// <param name="sigType">signature type to use</param>
        public void FacialExpressionSetSignatureType(UInt32 userId, EdkDll.IEE_FacialExpressionSignature_t sigType)
        {
            errorHandler(EdkDll.IEE_FacialExpressionSetSignatureType(userId, sigType));
        }

        /// <summary>
        /// Indicates whether the FacialExpression suite is currently using either the built-in, universal signature or a trained signature
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>receives the signature type currently in use</returns>
        public EdkDll.IEE_FacialExpressionSignature_t FacialExpressionGetSignatureType(UInt32 userId)
        {
            EdkDll.IEE_FacialExpressionSignature_t sigTypeOut;
            errorHandler(EdkDll.IEE_FacialExpressionGetSignatureType(userId, out sigTypeOut));
            return sigTypeOut;
        }

        /// <summary>
        /// Set the current MentalCommand active action types
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="activeActions">a bit vector composed of IEE_MentalCommandAction_t contants</param>
        public void MentalCommandSetActiveActions(UInt32 userId, UInt32 activeActions)
        {
            errorHandler(EdkDll.IEE_MentalCommandSetActiveActions(userId, activeActions));
        }

        /// <summary>
        /// Get the current MentalCommand active action types
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>receive a bit vector composed of IEE_MentalCommandAction_t contants</returns>
        public UInt32 MentalCommandGetActiveActions(UInt32 userId)
        {
            UInt32 activeActionsOut = 0;
            errorHandler(EdkDll.IEE_MentalCommandGetActiveActions(userId, out activeActionsOut));
            return activeActionsOut;
        }

        /// <summary>
        /// Return the duration of a MentalCommand training session
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>receive the training time in ms</returns>
        public UInt32 MentalCommandGetTrainingTime(UInt32 userId)
        {
            UInt32 trainingTimeOut = 0;
            errorHandler(EdkDll.IEE_MentalCommandGetTrainingTime(userId, out trainingTimeOut));
            return trainingTimeOut;
        }

        /// <summary>
        /// Set the training control flag for MentalCommand training
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="control">pre-defined MentalCommand training control</param>
        public void MentalCommandSetTrainingControl(UInt32 userId, EdkDll.IEE_MentalCommandTrainingControl_t control)
        {
            errorHandler(EdkDll.IEE_MentalCommandSetTrainingControl(userId, control));
        }

        /// <summary>
        /// Set the type of MentalCommand action to be trained
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="action">which action would like to be trained</param>
        public void MentalCommandSetTrainingAction(UInt32 userId, EdkDll.IEE_MentalCommandAction_t action)
        {
            errorHandler(EdkDll.IEE_MentalCommandSetTrainingAction(userId, action));
        }

        /// <summary>
        /// Get the type of MentalCommand action currently selected for training
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>action that is currently selected for training</returns>
        public EdkDll.IEE_MentalCommandAction_t MentalCommandGetTrainingAction(UInt32 userId)
        {
            EdkDll.IEE_MentalCommandAction_t actionOut;
            errorHandler(EdkDll.IEE_MentalCommandGetTrainingAction(userId, out actionOut));
            return actionOut;
        }

        /// <summary>
        /// Gets a list of the MentalCommand actions that have been trained by the user
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>receives a bit vector composed of IEE_MentalCommandAction_t contants</returns>
        public UInt32 MentalCommandGetTrainedSignatureActions(UInt32 userId)
        {
            UInt32 trainedActionsOut = 0;
            errorHandler(EdkDll.IEE_MentalCommandGetTrainedSignatureActions(userId, out trainedActionsOut));
            return trainedActionsOut;
        }

        /// <summary>
        /// Gets the current overall skill rating of the user in MentalCommand
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>receives the overall skill rating [from 0.0 to 1.0]</returns>
        public Single MentalCommandGetOverallSkillRating(UInt32 userId)
        {
            Single overallSkillRatingOut = 0.0F;
            errorHandler(EdkDll.IEE_MentalCommandGetOverallSkillRating(userId, out overallSkillRatingOut));
            return overallSkillRatingOut;
        }

        /// <summary>
        /// Gets the current skill rating for particular MentalCommand actions of the user
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="action">a particular action of IEE_MentalCommandAction_t contant</param>
        /// <returns>receives the action skill rating [from 0.0 to 1.0]</returns>
        public Single MentalCommandGetActionSkillRating(UInt32 userId, EdkDll.IEE_MentalCommandAction_t action)
        {
            Single actionSkillRatingOut = 0.0F;
            errorHandler(EdkDll.IEE_MentalCommandGetActionSkillRating(userId, action, out actionSkillRatingOut));
            return actionSkillRatingOut;
        }

        /// <summary>
        /// Set the overall sensitivity for all MentalCommand actions
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="level">sensitivity level of all actions (lowest: 1, highest: 7)</param>
        public void MentalCommandSetActivationLevel(UInt32 userId, Int32 level)
        {
            errorHandler(EdkDll.IEE_MentalCommandSetActivationLevel(userId, level));
        }

        /// <summary>
        /// Set the sensitivity of MentalCommand actions
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="action1Sensitivity">sensitivity of action 1 (min: 1, max: 10)</param>
        /// <param name="action2Sensitivity">sensitivity of action 2 (min: 1, max: 10)</param>
        /// <param name="action3Sensitivity">sensitivity of action 3 (min: 1, max: 10)</param>
        /// <param name="action4Sensitivity">sensitivity of action 4 (min: 1, max: 10)</param>
        public void MentalCommandSetActionSensitivity(UInt32 userId,
                                            Int32 action1Sensitivity, Int32 action2Sensitivity,
                                            Int32 action3Sensitivity, Int32 action4Sensitivity)
        {
            errorHandler(EdkDll.IEE_MentalCommandSetActionSensitivity(userId, action1Sensitivity, action2Sensitivity, action3Sensitivity, action4Sensitivity));
        }

        /// <summary>
        /// Get the overall sensitivity for all MentalCommand actions
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>sensitivity level of all actions (min: 1, max: 10)</returns>
        public Int32 MentalCommandGetActivationLevel(UInt32 userId)
        {
            Int32 levelOut = 0;
            errorHandler(EdkDll.IEE_MentalCommandGetActivationLevel(userId, out levelOut));
            return levelOut;
        }

        /// <summary>
        /// Query the sensitivity of MentalCommand actions
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="pAction1SensitivityOut">sensitivity of action 1</param>
        /// <param name="pAction2SensitivityOut">sensitivity of action 2</param>
        /// <param name="pAction3SensitivityOut">sensitivity of action 3</param>
        /// <param name="pAction4SensitivityOut">sensitivity of action 4</param>
        public void MentalCommandGetActionSensitivity(UInt32 userId,
                                            out Int32 pAction1SensitivityOut, out Int32 pAction2SensitivityOut,
                                            out Int32 pAction3SensitivityOut, out Int32 pAction4SensitivityOut)
        {
            errorHandler(EdkDll.IEE_MentalCommandGetActionSensitivity(userId, out pAction1SensitivityOut, out pAction2SensitivityOut,
                out pAction3SensitivityOut, out pAction4SensitivityOut));
        }

        /// <summary>
        /// Start the sampling of Neutral state in MentalCommand
        /// </summary>
        /// <param name="userId">user ID</param>
        public void MentalCommandStartSamplingNeutral(UInt32 userId)
        {
            errorHandler(EdkDll.IEE_MentalCommandStartSamplingNeutral(userId));
        }

        /// <summary>
        /// Stop the sampling of Neutral state in MentalCommand
        /// </summary>
        /// <param name="userId">user ID</param>
        public void MentalCommandStopSamplingNeutral(UInt32 userId)
        {
            errorHandler(EdkDll.IEE_MentalCommandStopSamplingNeutral(userId));
        }

        /// <summary>
        /// Enable or disable signature caching in MentalCommand
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="enabled">flag to set status of caching (1: enable, 0: disable)</param>
        public void MentalCommandSetSignatureCaching(UInt32 userId, UInt32 enabled)
        {
            errorHandler(EdkDll.IEE_MentalCommandSetSignatureCaching(userId, enabled));
        }

        /// <summary>
        /// Enable or disable signature caching in MentalCommand
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>flag to get status of caching (1: enable, 0: disable)</returns>
        public UInt32 MentalCommandGetSignatureCaching(UInt32 userId)
        {
            UInt32 enabledOut = 0;
            errorHandler(EdkDll.IEE_MentalCommandGetSignatureCaching(userId, out enabledOut));
            return enabledOut;
        }

        /// <summary>
        /// Set the cache size for the signature caching in MentalCommand
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="size">number of signatures to be kept in the cache (0: unlimited)</param>
        public void MentalCommandSetSignatureCacheSize(UInt32 userId, UInt32 size)
        {
            errorHandler(EdkDll.IEE_MentalCommandSetSignatureCacheSize(userId, size));
        }

        /// <summary>
        /// Get the current cache size for the signature caching in MentalCommand
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>number of signatures to be kept in the cache (0: unlimited)</returns>
        public UInt32 MentalCommandGetSignatureCacheSize(UInt32 userId)
        {
            UInt32 sizeOut = 0;
            errorHandler(EdkDll.IEE_MentalCommandGetSignatureCacheSize(userId, out sizeOut));
            return sizeOut;
        }

        /// <summary>
        /// Returns a struct containing details about the specified EEG channel's headset 
        /// </summary>
        /// <param name="channelId">channel identifier</param>
        /// <returns>provides detailed sensor location and other info</returns>
        public EdkDll.IInputSensorDescriptor_t HeadsetGetSensorDetails(EdkDll.IEE_InputChannels_t channelId)
        {
            EdkDll.IInputSensorDescriptor_t descriptorOut;
            errorHandler(EdkDll.IEE_HeadsetGetSensorDetails(channelId, out descriptorOut));
            return descriptorOut;
        }

        /// <summary>
        /// Returns the current hardware version of the headset and dongle for a particular user
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>hardware version for the user headset/dongle pair. hiword is headset version, loword is dongle version.</returns>
        public UInt32 HardwareGetVersion(UInt32 userId)
        {
            UInt32 hwVersionOut;
            errorHandler(EdkDll.IEE_HardwareGetVersion(userId, out hwVersionOut));
            return hwVersionOut;
        }

        /// <summary>
        /// Returns the current version of the Emotiv SDK software
        /// </summary>
        /// <param name="pszVersionOut">SDK software version in X.X.X.X format. Note: current beta releases have a major version of 0.</param>        
        /// <param name="pBuildNumOut">Build number.  Unique for each release.</param>
        public void SoftwareGetVersion(out String pszVersionOut, out UInt32 pBuildNumOut)
        {
            StringBuilder version = new StringBuilder(128);
            errorHandler(EdkDll.IEE_SoftwareGetVersion(version,(UInt32) version.Capacity, out pBuildNumOut));
            pszVersionOut = version.ToString();
        }

        /// <summary>
        /// Returns the delta of the movement of the gyro since the previous call for a particular user
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <param name="pXOut">horizontal displacement</param>
        /// <param name="pYOut">vertical displacment</param>
        public void HeadsetGetGyroDelta(UInt32 userId, out Int32 pXOut, out Int32 pYOut)
        {
            errorHandler(EdkDll.IEE_HeadsetGetGyroDelta(userId, out pXOut, out pYOut));
        }

        /// <summary>
        /// Re-zero the gyro for a particular user
        /// </summary>
        /// <param name="userId">user ID</param>
        public void HeadsetGyroRezero(UInt32 userId)
        {
            errorHandler(EdkDll.IEE_HeadsetGyroRezero(userId));
        }
      
        //Motion Data-------------

        /// <summary>
        /// Sets the size of the motion data buffer. The size of the buffer affects how frequent GetData() needs to be called to prevent data loss.
        /// </summary>
        /// <param name="bufferSizeInSec">buffer size in second</param>
        public void MotionDataSetBufferSizeInSec(Single bufferSizeInSec)
        {
            errorHandler(EdkDll.IEE_MotionDataSetBufferSizeInSec(bufferSizeInSec));
        }

        /// <summary>
        /// Returns the size of the motion data buffer
        /// </summary>        
        /// <returns>
        /// the size of the data buffer
        /// </returns>
        public Single MotionDataGetBufferSizeInSec()
        {
            Single bufferSizeInSecOut = 0;
            errorHandler(EdkDll.IEE_MotionDataGetBufferSizeInSec(out bufferSizeInSecOut));
            return bufferSizeInSecOut;
        }

        /// <summary>
        /// Returns latest data since the last call
        /// </summary>
        /// <param name="userId">user ID</param>
        /// <returns>
        /// receives latest data since the last call
        /// </returns>
        public Dictionary<EdkDll.IEE_MotionDataChannel_t, double[]> GetMotionData(UInt32 userId)
        {
            Dictionary<EdkDll.IEE_MotionDataChannel_t, double[]> result = new Dictionary<EdkDll.IEE_MotionDataChannel_t, double[]>();

            //errorHandler(EdkDll.IEE_MotionDataUpdateHandle(userId, hMotionData));
            EdkDll.IEE_MotionDataUpdateHandle(userId, hMotionData);

            UInt32 nSample = 10;
            errorHandler(EdkDll.IEE_MotionDataGetNumberOfSample(hMotionData, out nSample));

            if (nSample == 0)
            {
                return null;
            }

            foreach (EdkDll.IEE_MotionDataChannel_t channel in Enum.GetValues(typeof(EdkDll.IEE_MotionDataChannel_t)))
            {
                result.Add(channel, new double[nSample]);
                errorHandler(EdkDll.IEE_MotionDataGet(hMotionData, channel, result[channel], nSample));
            }

            return result;
        }

        /// <summary>
        /// Gets sampling rate
        /// </summary>
        /// <param name="userId">user ID</param>            
        public UInt32 MotionDataGetSamplingRate(UInt32 userId)
        {
            UInt32 samplingRate = 0;
            errorHandler(EdkDll.IEE_MotionDataGetSamplingRate(userId, out samplingRate));
            return samplingRate;
        }
    }
}
