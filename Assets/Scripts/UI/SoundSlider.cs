using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class SoundSlider : MonoBehaviour
{
    public AudioMixer AudioMixer;

    public void SetMusicVolume (float volume)
    {
        AudioMixer.SetFloat("GeneralMusic", volume);
    }

    public void SetAmbianceVolume (float volume)
    {
        AudioMixer.SetFloat("GeneralAmbiance", volume);
    }

    public void SetSFXVolume (float volume)
    {
        AudioMixer.SetFloat("GeneralSFX", volume);
    }
}
