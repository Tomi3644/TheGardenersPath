using UnityEngine;
using UnityEngine.Audio;
using System.Collections;
using System.Collections.Generic;


public class MusicManager : MonoBehaviour
{

    [Header("Sources")]
    [SerializeField] private AudioSource musicSourceMain;
    [SerializeField] private AudioSource musicSourceCave;
    [SerializeField] private AudioSource forestAmbianceSource;

    [Header("Others")]
    [SerializeField] private AudioMixer mixer;
    public List<AudioClip> audioClips = new List<AudioClip>();

    private Dictionary<SoundChannel, string> groupVolumesID = new Dictionary<SoundChannel, string>
    {
        [SoundChannel.MusicMain] = "MusicVolume1",
        [SoundChannel.MusicCave] = "MusicVolume2",
        [SoundChannel.ForestAmbiance] = "AmbianceVolume1",
        [SoundChannel.RiverAmbiance] = "AmbianceVolume2",
        [SoundChannel.CaveAmbiance] = "AmbianceVolume3"
    };

    public void ChangeMainSourceClip(AudioClip clip)
    {
        musicSourceMain.clip = clip;
    }

    public void PlayStopClip(bool play, bool isCave)
    {
        if (play)
        {
            musicSourceMain.Play();
            if (isCave) musicSourceCave.Play();
        }
        else
        {
            musicSourceMain.Stop();
            if (isCave) musicSourceCave.Stop();
        }
    }

    public IEnumerator FadeTrack(SoundChannel channel, float targetVolume)
    {
        string targetGroupVolume = groupVolumesID.GetValueOrDefault(channel);
        float timeToFade = 1.25f;
        float elapsedTime = 0;
        mixer.GetFloat(targetGroupVolume, out float startVolume);

        while (elapsedTime < timeToFade)
        {
            elapsedTime += Time.deltaTime;
            mixer.SetFloat(targetGroupVolume, Mathf.Lerp(startVolume, targetVolume, elapsedTime / timeToFade));
            print(elapsedTime);
            yield return null;
        }
        yield break;
    }

}

public enum SoundChannel
{
    MusicMain,
    MusicCave,
    ForestAmbiance,
    RiverAmbiance,
    CaveAmbiance
};
